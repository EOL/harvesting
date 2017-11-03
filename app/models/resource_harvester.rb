# NOTE: you probably want to look at the .store method.
class ResourceHarvester
  attr_accessor :resource, :harvest, :format, :line_num, :diff, :file, :parser, :headers

  class << self
    def by_id(id)
      ResourceHarvester.new(Resource.find(id)).start
    end

    def by_abbr(abbr)
      ResourceHarvester.new(Resource.where(abbr: abbr).first).start
    end
  end

  # NOTE: Composition pattern, here. Too much to have in one file:
  include Store::Boolean
  include Store::Nodes
  include Store::Media
  include Store::Vernaculars
  include Store::Traits
  include Store::Occurrences
  include Store::References
  include Store::ModelBuilder

  def initialize(resource, harvest = nil)
    # TODO: this is WAAAY too tighly coupled with the model builder class (at least)
    @resource = resource
    @previous_harvest = @resource.harvests&.completed&.last
    @harvest = nil
    @uris = {}
    @formats = {}
    @harvest = harvest
    @default_trait_resource_pk = 0
    @converted = {}
    # Placeholders to mark where we "currently are":
    @diff = nil
    @line_num = 0
    @format = 'none'
    @file = '/dev/null'
    @parser = nil
    @headers = []
  end

  def resume
    @harvest = @resource.harvests.last
    raise "Previous harvest completed!" if @harvest.completed?
    @previous_harvest = @resource.harvests.completed[-2] if @harvest == @previous_harvest
    start
  end

  def inspect
    "<Harvester @resource=#{@resource.id}"\
      " @harvest=#{@harvest.try(:id) || 'nil'}"\
      " @uris.count=#{@uris.keys.count}"\
      " READING: +#{@line_num} #{@file} (#{@format.try(:represents) || 'no format'}) @headers=#{@headers.join(',')}"\
      '>'
  end

  def start
    @start_time = Time.now
    Searchkick.disable_callbacks
    begin
      fast_forward = @harvest && !@harvest.stage.nil?
      steps = Harvest.stages.keys.each do |stage|
        if fast_forward && harvest.stage != stage
          @harvest.log("Already completed stage #{stage}, skipping...", cat: :infos)
          next
        end
        fast_forward = false
        @harvest.send("#{stage}!") if @harvest # there isn't a @harvest on the first step.
        self.send(stage)
      end
    rescue => e
      if @harvest
        log_err(e, 'harvest failed')
        @harvest.update_attribute(:failed_at, Time.now)
      end
      debugger
      4
    ensure
      Searchkick.enable_callbacks
      @harvest.log("}} Harvest ends for #{@resource.name} (#{@resource.id})", cat: :ends) if @harvest
    end
  end

  def create_harvest_instance
    @harvest = @resource.create_harvest_instance
    @harvest.create_harvest_instance!
    @harvest.log("{{ Harvest begins for #{@resource.name} (#{@resource.id})", cat: :starts)
  end

  # grab the file from each format
  def fetch_files
    Harvest::Fetcher.fetch_format_files(@harvest)
    @harvest.update_attribute(:fetched_at, Time.now)
  end

  def validate_each_file
    # TODO ... this should check ID consistentcy too...
    # @harvest.update_attribute(:consistency_checked_at, Time.now)
    # TODO: I don't think the mkdirs do not belong here. I wasn't sure where would be best. TODO: really the dir names
    # here (and the one in format.rb) should be configurable
    Dir.mkdir(Rails.public_path.join('converted_csv')) unless
      Dir.exist?(Rails.public_path.join('converted_csv'))
    @harvest.log_call
    each_format do
      fields = {}
      expected_by_file = @headers.dup
      @format.fields.each_with_index do |field, i|
        raise(Exceptions::ColumnMissing, field.expected_header) if @headers[i].nil?
        debugger unless field.expected_header == @headers[i]
        raise(Exceptions::ColumnMismatch,
              "expected '#{field.expected_header}' as column #{i}, but got '#{@headers[i]}'") unless
          field.expected_header == @headers[i]
        fields[@headers[i]] = field
        expected_by_file.delete(@headers[i])
      end
      raise(Exceptions::ColumnUnmatched, expected_by_file.join(',')) if expected_by_file.size.positive?
      @file = @format.converted_csv_path
      CSV.open(@file, 'wb', encoding: 'ISO-8859-1') do |csv|
        @parser.rows_as_hashes do |row, line|
          @line_num = line
          csv_row = []
          @headers.each do |header|
            check = fields[header]
            next unless check
            val = row[header]
            if val.blank?
              log_warning("Illegal empty value for #{header}") unless check.can_be_empty?
            end
            if check.must_be_integers?
              unless row[header] =~ /\a[\d,]+\z/m
                log_warning("Illegal non-integer for #{header}, got #{val}")
              end
            elsif check.must_know_uris?
              unless uri_exists?(val)
                log_warning("Illegal unknown URI <#{val}> for #{header}")
              end
            end
            csv_row << val
          end
          csv << csv_row
        end
      end
      @converted[@format.id] = true
    end
    @harvest.update_attribute(:validated_at, Time.now)
  end

  def convert_to_csv
    @harvest.log_call
    each_format do
      unless @converted[@format.id]
        @file = @format.converted_csv_path
        CSV.open(@file, 'wb', encoding: 'ISO-8859-1') do |csv|
          @parser.rows_as_hashes do |row, line|
            csv_row = []
            @headers.each do |header|
              csv_row << row[header]
            end
            csv << csv_row
          end
        end
        @converted[@format.id] = true # Shouldn't need this, but being safe
      end
      cmd = "/usr/bin/sort #{@format.converted_csv_path} > "\
            "#{@format.converted_csv_path}_sorted"
      log_cmd(cmd)
      if system(cmd)
        FileUtils.mv("#{@format.converted_csv_path}_sorted", @format.converted_csv_path)
      else
        raise "Failed system call { #{cmd} } #{$CHILD_STATUS}"
      end
    end
  end

  def uri_exists?(uri)
    return true if @uris.key?(uri)
    if Term.where(uri: uri).exists?
      @uris[uri] = true
    else
      false
    end
  end

  def calculate_delta
    # TODO: really this dir name (and the one in format.rb) should be configurable
    Dir.mkdir(Rails.public_path.join('diff')) unless
      Dir.exist?(Rails.public_path.join('diff'))
    each_format do
      @format.update_attribute(:diff, @format.diff_path)
      other_fmt = @previous_harvest ? @previous_harvest.formats.find { |f| f.represents == @format.represents } : nil
      @file = @format.diff # We're now reading from the diff...
      # There's no diff if the previous format failed!
      if other_fmt && File.exist?(other_fmt.converted_csv_path)
        diff(other_fmt)
      else
        fake_diff_from_nothing
      end
    end
    @harvest.update_attribute(:deltas_created_at, Time.now)
  end

  def diff(old_fmt)
    File.unlink(@format.diff) if File.exist?(@format.diff)
    cmd = "/usr/bin/diff #{old_fmt.converted_csv_path} "\
      "#{@format.converted_csv_path} > #{@format.diff}"
    # TODO: We can't trust the exit code! diff exits 0 if the files are the
    # same, and 1 if not.
    run_cmd(cmd)
  end

  def fake_diff_from_nothing
    run_cmd("echo \"0a\" > #{@format.diff}")
    run_cmd("tail -n +#{@format.data_begins_on_line} #{@format.converted_csv_path} >> #{@format.diff}")
    run_cmd("echo \".\" >> #{@format.diff}")
  end

  def run_cmd(cmd)
    log_cmd(cmd)
    system(cmd)
  end

  # read the raw new/updated data into the database, TODO: log curation conflicts
  def parse_diff_and_store
    clear_storage_vars
    each_diff do
      log_info "Loading #{@format.represents} (#{@format.id}) diff file into memory..."
      fields = build_fields
      i = 0
      any_diff = @parser.diff_as_hashes(@headers) do |row|
        i += 1
        log_info("row #{i}") if (i % 100_000).zero?
        @file = @parser.path_to_file
        @diff = @parser.diff
        reset_row
        begin
          @headers.each do |header|
            field = fields[header]
            next if row[header].blank?
            next if field.to_ignored?
            # NOTE: that these methods are defined in the Store::* mixins:
            send(field.mapping, field, row[header])
          end
        rescue => e
          log_info "Failed to parse row #{@line_num}..."
          debugger
          raise e
        end
        begin
          # NOTE: see Store::ModelBuilder mixin for the methods called here:
          # (Why? Composition.)
          if @diff == :removed
            destroy_for_fmt
          else # new or changed
            build_models
          end
        rescue => e
          log_err(e, "Failed to save data from row #{@line_num}...")
          debugger
          raise e
          # end
        end
      end
      log_warning('There were no differences in this file!') unless any_diff
    end
    find_orphan_parent_nodes
    find_duplicate_nodes
    store_new
    mark_old
    clear_storage_vars # Allow GC to clean up!
  end

  def clear_storage_vars
    @harvest.log_call
    @nodes_by_ancestry = {}
    @terms = {}
    @models = {}
    @new = {}
    @old = {}
  end

  def find_orphan_parent_nodes
    # TODO - if the resource gave us parent IDs, we *could* have unresolved ids that we need to flag.
  end

  def find_duplicate_nodes
    # TODO - look for shared parents and primary keys.
  end

  # TODO - extract to Store::Storage
  def store_new
    @new.each do |klass, models|
      log_info "Storing #{models.size} #{klass.name.pluralize}"
      begin
        # Grouping them might not be necssary, but it sure makes debugging easier...
        group_size = 1000
        g_count = 1
        models.in_groups_of(group_size, false) do |group|
          log_info "... #{g_count * group_size}" if (g_count % 10).zero?
          g_count += 1
          klass.import! group
        end
      rescue => e
        debugger
        1
      end
    end
    @harvest.update_attribute(:stored_at, Time.now)
  end

  # TODO - extract to Store::Storage
  def mark_old
    @old.each do |klass, by_keys|
      log_info("Marking old #{klass.name}") unless by_keys.empty?
      by_keys.each do |key, pks|
        pks.in_groups_of(1000, false) do |group|
          begin
            klass.send(:where, { key => group, :resource_id => @resource.id }).
              update_all(removed_by_harvest_id: @harvest.id)
          rescue => e
            debugger
            2
          end
        end
      end
    end
  end

  def resolve_missing_media_owners
    # TODO
  end

  def rebuild_nodes
    @harvest.log_call
    Flattener.flatten(@resource)
    @harvest.update_attribute(:ancestry_built_at, Time.now)
  end

  def resolve_node_keys
    @harvest.log_call
    # Node ancestry:
    propagate_id(Node, fk: 'parent_resource_pk', other: 'nodes.resource_pk', set: 'parent_id', with: 'id')
    # Node scientific names:
    propagate_id(Node, fk: 'resource_pk', other: 'scientific_names.node_resource_pk',
                       set: 'scientific_name_id', with: 'id')
    # Scientific names to nodes:
    propagate_id(ScientificName, fk: 'node_resource_pk', other: 'nodes.resource_pk', set: 'node_id', with: 'id')
    # Vernaculars to nodes:
    propagate_id(Vernacular, fk: 'node_resource_pk', other: 'nodes.resource_pk', set: 'node_id', with: 'id')
    # And identifiers to nodes:
    propagate_id(Identifier, fk: 'node_resource_pk', other: 'nodes.resource_pk', set: 'node_id', with: 'id')
  end

  def resolve_media_keys
    @harvest.log_call
    # Media to nodes:
    propagate_id(Medium, fk: 'node_resource_pk', other: 'nodes.resource_pk', set: 'node_id', with: 'id')
    resolve_references(MediaReference, 'medium')
  end

  def resolve_trait_keys
    @harvest.log_call
    # Occurrences to nodes:
    log_info('Occurrences to nodes...')
    propagate_id(Occurrence, fk: 'node_resource_pk', other: 'nodes.resource_pk', set: 'node_id', with: 'id')
    propagate_id(OccurrenceMetadatum, fk: 'occurrence_resource_pk', other: 'occurrences.resource_pk',
                                      set: 'occurrence_id', with: 'id')
    # Traits to nodes (through occurrences)
    log_info('traits to nodes...')
    propagate_id(Trait, fk: 'occurrence_resource_pk', other: 'occurrences.resource_pk', set: 'node_id', with: 'node_id')
    # Traits to sex term:
    log_info('Traits to sex term...')
    propagate_id(Trait, fk: 'occurrence_resource_pk', other: 'occurrences.resource_pk',
                        set: 'sex_term_id', with: 'sex_term_id')
    # Traits to lifestage term:
    log_info('Traits to lifestage term...')
    propagate_id(Trait, fk: 'occurrence_resource_pk', other: 'occurrences.resource_pk',
                        set: 'lifestage_term_id', with: 'lifestage_term_id')
    # MetaTraits to traits:
    log_info('MetaTraits to traits...')
    propagate_id(MetaTrait, fk: 'trait_resource_pk', other: 'traits.resource_pk', set: 'trait_id', with: 'id')
    # MetaTraits (simple, measurement row refers to parent) to traits:
    log_info('MetaTraits (simple, measurement row refers to parent) to traits...')
    propagate_id(Trait, fk: 'parent_pk', other: 'traits.resource_pk', set: 'parent_id', with: 'id')

    # TODO: transfer the lat, long, and locality from occurrences to traits... (I don't think we caputure these yet)
    # TODO: traits that are assocs! Yeesh.
  end

  def resolve_references(klass, singular)
    # TODO: this ALSO belongs in the other two keys blocks:
    # Media to references, and back:
    propagate_id(klass, fk: "#{singular}_resource_fk", other: "#{singular.pluralize}.resource_pk",
                        set: "#{singular}_id", with: 'id')
    propagate_id(klass, fk: 'ref_resource_fk', other: 'references.resource_pk',
                        set: 'reference_id', with: 'id')
  end

  def add_occurrence_metadata_to_traits
    @harvest.log_call
    meta_traits = []
    OccurrenceMetadata.includes(:occurrence).where(harvest_id: @harvest.id).find_each do |meta|
      # NOTE: this is probably not very efficient. :S
      meta.occurrence.traits.each do |trait|
        meta_traits <<
          MetaTrait.new(predicate_term_id: meta.predicate_term_id, object_term_id: meta.object_term_id,
                        harvest_id: @harvest.id, resource_id: @resource.id, trait_id: trait.id)
      end
    end
    MetaTrait.import!(meta_traits) unless meta_traits.empty?
  end

  def resolve_missing_parents
    @harvest.log_call
    propagate_id(Node, fk: 'parent_resource_pk', other: 'nodes.resource_pk', set: 'parent_id', with: 'id')
  end

  def propagate_id(klass, options = {})
    klass.propagate_id(options.merge(harvest_id: @harvest.id))
  end

  def log_info(what)
    @harvest.log(what, cat: :infos)
  end

  def log_cmd(what)
    @harvest.log(what, cat: :commands)
  end

  def log_err(e, msg)
    @harvest.log("#{msg}: #{e.message}", e: e, cat: :errors)
    e.backtrace.each do |trace|
      last if trace =~ /\/bundler/
      @harvest.log(trace, cat: :errors)
    end
    @harvest.update_attribute(:failed_at, Time.now)
  end

  def log_warning(msg)
    @format.warn(msg, @line_num)
  end

  def build_fields
    fields = {}
    @format.fields.each_with_index do |field, i|
      fields[@headers[i]] = field
    end
    fields
  end

  def sanitize_media_verbatims
    # TODO
  end

  def queue_downloads
    @harvest.log_call
    @harvest.media.find_each { |med| med.delay.download_and_resize }
  end

  def parse_names
    @harvest.log_call
    NameParser.for_harvest(@harvest)
    @harvest.update_attribute(:names_parsed_at, Time.now)
  end

  def denormalize_canonical_names_to_nodes
    @harvest.log_call
    propagate_id(Node, fk: 'scientific_name_id', other: 'scientific_names.id', set: 'canonical', with: 'canonical')
  end

  # match node names against the DWH, store "hints", report on unmatched
  # nodes, consider the effects of curation
  def match_nodes
    @harvest.log_call
    NamesMatcher.for_harvest(@harvest)
    @harvest.update_attribute(:nodes_matched_at, Time.now)
  end

  def reindex_search
    @harvest.log_call
    # TODO: I don't think we *need* to enable/disable, here... but I'm being safe:
    Searchkick.enable_callbacks
    Node.where(harvest_id: @harvest.id).reindex
    Searchkick.disable_callbacks
    @harvest.update_attribute(:indexed_at, Time.now)
  end

  def normalize_units
    # TODO: later...
    @harvest.update_attribute(:units_normalized_at, Time.now)
  end

  # add links and build links to DOI and the like (and find missing DOIs)
  def link
    # TODO: later...
    @harvest.update_attribute(:linked_at, Time.now)
  end

  def calculate_statistics
    # TODO: (LOW-PRIO)...
  end

  # send notifications and finish up the instance:
  def complete_harvest_instance
    @harvest.complete
  end

  def each_format(&block)
    @harvest.formats.each do |fmt|
      @format = fmt
      fid = @format.id
      unless @formats.has_key?(fid)
        @formats[fid] = {}
        @file = @format.file
        raise "File missing!" unless File.exist?(@file)
        @formats[fid][:parser] = if @format.excel?
            ExcelParser.new(@file, sheet: @format.sheet,
              header_lines: @format.header_lines,
              data_begins_on_line: @format.data_begins_on_line)
          elsif @format.csv?
            CsvParser.new(@file, field_sep: @format.field_sep,
              line_sep: @format.line_sep, header_lines: @format.header_lines,
              data_begins_on_line: @format.data_begins_on_line)
          else
            raise "I don't know how to read formats of #{@format.file_type}!"
          end
        @formats[fid][:headers] = @formats[fid][:parser].headers
      end
      @parser = @formats[fid][:parser]
      @headers = @formats[fid][:headers]
      yield
    end
  end

  # This is very much like #each_format, but reads the diff file and ignores the
  # headers in the file (it uses the DB instead)...
  def each_diff(&block)
    @harvest.formats.each do |fmt|
      @format = fmt
      fid = "#{@format.id}_diff".to_sym
      unless @formats.has_key?(fid)
        @formats[fid] = {}
        @formats[fid][:parser] = CsvParser.new(@format.diff)
        @formats[fid][:headers] = @format.fields.sort_by(&:position).map(&:expected_header)
      end
      @parser = @formats[fid][:parser]
      @headers = @formats[fid][:headers]
      @file = @format.diff
      yield
    end
  end

  def completed
    @harvest.update_attribute(:completed_at, Time.now)
    @harvest.update_attribute(:time_in_minutes, ((Time.now - @start_time).to_i / 60.0).ceil)
    @harvest.log("Harvest of #{@harvest.resource.name} completed.", cat: :ends)
  end
end
