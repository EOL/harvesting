class ResourceHarvester
  attr_accessor :resource, :harvest, :format, :line_num, :diff, :file, :parser, :headers

  # TODO: ignore headers, if there aren't any
  # TODO: skip lines where the identifier is missing.

  class << self
    def by_id(id)
      ResourceHarvester.new(Resource.find(id)).start
    end

    def by_abbr(abbr)
      ResourceHarvester.new(Resource.where(abbr: abbr).first).start
    end
  end

  # NOTE: Composition pattern, here. Too much to have in one file:
  include Store::Assocs
  include Store::Attributions
  include Store::Boolean
  include Store::Media # NOTE: this also handles import of Articles, since they are in one file.
  include Store::ModelBuilder
  include Store::Nodes
  include Store::Occurrences
  include Store::References
  include Store::Traits
  include Store::Vernaculars

  def initialize(resource)
    # TODO: this is WAAAY too tighly coupled with the model builder class (at least)
    @resource = resource
    @previous_harvest = @resource.harvests&.completed&.last
    @uris = {}
    @formats = {}
    @harvest = nil
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
    prep_resume
    start
  end

  def prep_resume
    @harvest = @resource.harvests.last
    raise('Previous harvest completed!') if @harvest.completed?
    @previous_harvest = @resource.harvests.complete_non_failed[-2] if @harvest == @previous_harvest
    @resource.publishing!
    @harvest.update_attribute(:failed_at, nil)
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
    @resource.lock do
      begin
        fast_forward = @harvest && !@harvest.stage.nil?
        Harvest.stages.each_key do |stage|
          if fast_forward && harvest.stage != stage
            @harvest.log("Already completed stage #{stage}, skipping...", cat: :infos)
            next
          # NOTE I'm not calling @resource.harvests here, since I want the query to run, not use cache:
          elsif Harvest.where(resource_id: @resource.id).running.count > 1
            harvest_ids = Harvest.where(resource_id: @resource.id).running.pluck(:id)
            raise(Exception, "MULTIPLE HARVESTS RUNNING FOR THIS RESOURCE: #{harvest_ids.join(', ')}")
          end
          fast_forward = false
          @harvest.send("#{stage}!") if @harvest # there isn't a @harvest on the first step.
          send(stage)
        end
      rescue Lockfile::TimeoutLockError => e
        if @harvest
          log_err(Exception.new('Already running!'))
        end
      rescue => e
        if @harvest
          log_err(e)
        end
        @resource.stop_adding_media_jobs if @resource
      ensure
        Searchkick.enable_callbacks
        took = Time.delta_s(@start_time)
        @harvest.log("}} Harvest ends for #{@resource.name} (#{@resource.id}), took #{took}", cat: :ends) if @harvest
      end
    end
  end

  def create_harvest_instance
    @harvest = @resource.create_harvest_instance
    @harvest.create_harvest_instance!
    @harvest.log("{{ Harvest begins for #{@resource.name} (#{@resource.id})", cat: :starts)
  end

  # grab the file from each format
  def fetch_files
    unless @resource.any_files_changed?
      raise 'No files have changed!'
    end
    # TODO: we should compress the files.
    # https://stackoverflow.com/questions/9204423/how-to-unzip-a-file-in-ruby-on-rails
    Harvest::Fetcher.fetch_format_files(@harvest)
    @harvest.update_attribute(:fetched_at, Time.now)
  end

  # TODO: Clean the code for the next few methods. This was pretty sloppy.
  # TODO: Sanity checks. Is there a really long line in the file, for example?
  def validate_each_file
    # TODO: this should check ID consistentcy too...
    # @harvest.update_attribute(:consistency_checked_at, Time.now)
    # TODO: I don't think the mkdirs belong here. I wasn't sure where would be best. TODO: really the dir names
    # here (and the one in format.rb) should be configurable
    Dir.mkdir(Rails.public_path.join('converted_csv')) unless
      Dir.exist?(Rails.public_path.join('converted_csv'))
    @harvest.log_call
    each_format do
      fields = nil # scope.
      if @format.header_lines.positive?
        col_checks = check_each_column
        expected_by_file = col_checks[:expected]
        fields = col_checks[:fields]
        raise(Exceptions::ColumnUnmatched, "TOO MANY COLUMNS: #{@format.represents}: #{expected_by_file.join(',')}") if
          expected_by_file.size.positive?
      else
        fields = {}
        @format.fields.each { |f| fields[f.expected_header] = f }
      end
      @file = @format.converted_csv_path
      CSV.open(@file, 'wb', encoding: 'UTF-8') do |csv|
        validate_csv(csv, fields)
      end
      @converted[@format.id] = true
    end
    @harvest.update_attribute(:validated_at, Time.now)
  end

  def check_each_column
    fields = {}
    expected_by_file = @headers.dup
    @format.fields.each_with_index do |field, i|
      raise(Exceptions::ColumnMissing, "MISSING COLUMN: #{@format.represents}: #{field.expected_header}") if
        @headers[i].nil?
      actual_header = strip_quotes(@headers[i])
      unless strip_quotes(field.expected_header).downcase == actual_header.downcase
        raise(Exceptions::ColumnMismatch, "COLUMN MISMATCH: #{@format.represents} expected "\
          "'#{field.expected_header}' as column #{i}, but got '#{actual_header}'")
      end
      fields[@headers[i]] = field
      expected_by_file.delete(@headers[i])
    end
    { expected: expected_by_file, fields: fields }
  end

  def strip_quotes(string)
    out = string.dup
    out.sub!(/^"/, '').sub!(/"$/, '') if out&.match?(/^".*"$/)
    out.sub!(/^'/, '').sub!(/'$/, '') if out&.match?(/^'.*'$/)
    out
  end

  def validate_csv(csv, fields)
    @parser.rows_as_hashes do |row, line|
      @line_num = line
      csv_row = []
      @headers.each do |header|
        check_header(csv_row, fields, row, header)
      end
      csv << csv_row
    end
  end

  def check_header(csv_row, fields, row, header)
    check = fields[header]
    return unless check
    val = row[header]
    if val.blank?
      unless check.can_be_empty?
        raise(Exceptions::ColumnEmpty, "Illegal empty value for #{@format.represents}/#{header} "\
          "on line #{@line_num}")
      end
    end
    if check.must_be_integers?
      unless row[header].match?(/\a[\d,]+\z/m)
        raise(Exceptions::ColumnNonInteger, "Illegal non-integer for #{@format.represents}/#{header} "\
          "on line #{@line_num}, got #{val}")
      end
    elsif check.must_know_uris?
      unless uri_exists?(val)
        raise(Exceptions::ColumnUnknownUri, "Illegal unknown URI <#{val}> for "\
          "#{@format.represents}/#{header} on line #{@line_num}")
      end
    end
    csv_row << val
  end

  def convert_to_csv
    @harvest.log_call
    each_format do
      unless @converted[@format.id]
        @file = @format.converted_csv_path
        CSV.open(@file, 'wb', encoding: 'UTF-8') do |csv|
          @parser.rows_as_hashes do |row, line|
            @line_num = line
            csv_row = []
            @headers.each do |header|
              # Un-quote values; we use a special quote char:
              val = strip_quotes(row[header])
              csv_row << val
            end
            csv << csv_row
          end
        end
        @converted[@format.id] = true # Shouldn't need this, but being safe
      end
      path = @format.converted_csv_path.to_s.gsub(' ', '\\ ')
      cmd = "/usr/bin/sort #{path} > #{path}_sorted"
      log_cmd(cmd)
      # NOTE: the LC_ALL fixes a problem with unicode characters.
      if system({'LC_ALL' => 'C'}, cmd)
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
    each_format(type: :converted) do
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
    # TODO: We can't trust the exit code! diff exits 0 if the files are the same, and 1 if not.
    run_cmd(cmd, {'LC_ALL' => 'C'})
  end

  def fake_diff_from_nothing
    diff = @format.diff.to_s.gsub(' ', '\\ ')
    csv = @format.converted_csv_path.to_s.gsub(' ', '\\ ')
    run_cmd("echo \"0a\" > #{diff}")
    if @format.data_begins_on_line.zero?
      run_cmd("cat #{csv} >> #{diff}")
    else
      run_cmd("tail -n +#{@format.data_begins_on_line} #{csv} >> #{diff}")
    end
    run_cmd("echo \".\" >> #{diff}")
  end

  def run_cmd(cmd, env = {})
    log_cmd(cmd)
    # NOTE: the LC_ALL fixes a problem with diff.
    if env.blank?
      system(cmd)
    else
      system(env, cmd)
    end
  end

  # read the raw new/updated data into the database, TODO: log curation conflicts
  def parse_diff_and_store
    clear_storage_vars
    each_diff do
      log_info "Loading #{@format.represents} (##{@format.id}) diff file into memory (#{@format.diff_size} lines)..."
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
            if row[header].blank?
              if field.default_when_blank
                row[header] = field.default_when_blank
              else
                next # Skip this value.
              end
            end
            next if field.to_ignored?
            raise "NO HANDLER FOR '#{field.mapping}'!" unless self.respond_to?(field.mapping)
            # NOTE: that these methods are defined in the Store::* mixins:
            send(field.mapping, field, row[header])
          end
        rescue => e
          log_info "Failed to parse row #{@line_num}..."
          raise e
        end
        # NOTE: see Store::ModelBuilder mixin for the methods called here. (Why aren't they here? Composition.)
        if @diff == :removed
          destroy_for_fmt
        else # new or changed
          build_models
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
    @missing_media_types = {}
    @bad_statuses = {}
    @warned = {}
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
      # Grouping them might not be necssary, but it sure makes debugging easier...
      group_size = 1000
      g_count = 1
      models.in_groups_of(group_size, false) do |group|
        log_info "... #{g_count * group_size}" if (g_count % 10).zero?
        g_count += 1
        # TODO: we should probably detect and handle duplicates: it shouldn't happen but it would be bad if it did.
        # DB validations are adequate and we want to go faster:
        begin
          klass.import! group, validate: false
        rescue => e
          if e.message =~ /row (\d+)\b/
            row = Regexp.last_match(1).to_i
            raise "#{e.class} while parsing something around here: #{group[row-1..row+1]}"
          else
            group.each do |instance|
              klass.import! [instance], validate: false # Let it fail on the single row that had a problem!
            end
          end
        end
      end
    end
    @harvest.update_attribute(:stored_at, Time.now)
  end

  # TODO: extract to Store::Storage
  def mark_old
    @old.each do |klass, by_keys|
      log_info("Marking old #{klass.name}") unless by_keys.empty?
      by_keys.each do |key, pks|
        pks.in_groups_of(1000, false) do |group|
          klass.send(:where, key => group, :resource_id => @resource.id).update_all(removed_by_harvest_id: @harvest.id)
        end
      end
    end
  end

  def resolve_missing_media_owners
    # TODO
  end

  def rebuild_nodes
    @harvest.log_call
    Flattener.flatten(@resource, @harvest)
    @harvest.update_attribute(:ancestry_built_at, Time.now)
  end

  def resolve_keys
    resolve_node_keys
    resolve_media_keys
    resolve_article_keys
    resolve_trait_keys
    resolve_attribution_keys
  end

  def hold_for_later_1
    # NOTE: I'm just reserving this slot in the harvest for something later.
  end

  def hold_for_later_2
    # NOTE: I'm just reserving this slot in the harvest for something later.
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
    resolve_references(NodesReference, 'node')
  end

  def resolve_media_keys
    @harvest.log_call
    # Media to nodes:
    propagate_id(Medium, fk: 'node_resource_pk', other: 'nodes.resource_pk', set: 'node_id', with: 'id')
    # Bib_cit:
    propagate_id(Medium, fk: 'resource_pk', other: 'bibliographic_citations.resource_pk',
                          set: 'bibliographic_citation_id', with: 'id')
    resolve_references(MediaReference, 'medium')
    resolve_attributions(Medium)
  end

  def resolve_article_keys
    @harvest.log_call
    # To nodes:
    propagate_id(Article, fk: 'node_resource_pk', other: 'nodes.resource_pk', set: 'node_id', with: 'id')
    # To sections:
    propagate_id(ArticlesSection, fk: 'article_pk', other: 'articles.resource_pk', set: 'article_id', with: 'id')
    # Bib_cit:
    propagate_id(Article, fk: 'resource_pk', other: 'bibliographic_citations.resource_pk',
                          set: 'bibliographic_citation_id', with: 'id')

    resolve_references(ArticlesReference, 'article')
    resolve_attributions(Article) # Yes, I know, we don't really have articles yet, but I don't want to forget this.
  end

  def resolve_trait_keys
    @harvest.log_call
    log_info('Occurrences to nodes (through scientific_names)...')
    propagate_id(Occurrence, fk: 'node_resource_pk', other: 'scientific_names.resource_pk',
                             set: 'node_id', with: 'node_id')
    propagate_id(OccurrenceMetadatum, fk: 'occurrence_resource_pk', other: 'occurrences.resource_pk',
                                      set: 'occurrence_id', with: 'id')
    log_info('traits to occurrences...')
    propagate_id(Trait, fk: 'occurrence_resource_pk', other: 'occurrences.resource_pk',
                        set: 'occurrence_id', with: 'id')
    log_info('traits to nodes (through occurrences)...')
    propagate_id(Trait, fk: 'occurrence_id', other: 'occurrences.id', set: 'node_id', with: 'node_id')
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
    resolve_references(TraitsReference, 'trait')
    # NOTE: JH: "please do [ignore agents for data]. The Contributor column data is appearing in beta, so you’re putting
    # it somewhere, and that’s all that matters for mvp"
    # resolve_attributions(Trait)

    log_info('Assocs to occurrences...')
    propagate_id(Assoc, fk: 'occurrence_resource_fk', other: 'occurrences.resource_pk',
                        set: 'occurrence_id', with: 'id')
    propagate_id(Assoc, fk: 'target_occurrence_resource_fk', other: 'occurrences.resource_pk',
                        set: 'target_occurrence_id', with: 'id')
    # Assoc to nodes (through occurrences)
    log_info('Assocs to nodes...')
    propagate_id(Assoc, fk: 'occurrence_id', other: 'occurrences.id', set: 'node_id', with: 'node_id')
    propagate_id(Assoc, fk: 'target_occurrence_id', other: 'occurrences.id',
                        set: 'target_node_id', with: 'node_id')
    # Assoc to sex term:
    log_info('Assoc to sex term...')
    propagate_id(Assoc, fk: 'occurrence_id', other: 'occurrences.id',
                        set: 'sex_term_id', with: 'sex_term_id')
    # Assoc to lifestage term:
    log_info('Assoc to lifestage term...')
    propagate_id(Assoc, fk: 'occurrence_id', other: 'occurrences.id',
                        set: 'lifestage_term_id', with: 'lifestage_term_id')
    # MetaAssoc to assocs:
    # TODO: this is not handled during harvest, yet.
    # log_info('MetaAssoc to assocs...')
    propagate_id(MetaAssoc, fk: 'assoc_resource_pk', other: 'assocs.resource_pk', set: 'assoc_id', with: 'id')
    resolve_references(AssocsReference, 'assoc')
    # NOTE: JH: "please do [ignore agents for data]. The Contributor column data is appearing in beta, so you’re putting
    # it somewhere, and that’s all that matters for mvp"
    # resolve_attributions(Assoc)
    # TODO: transfer the lat, long, and locality from occurrences to traits and assocs... (I don't think we caputure
    # these yet)
  end

  def resolve_references(klass, singular)
    propagate_id(klass, fk: "#{singular}_resource_fk", other: "#{singular.pluralize}.resource_pk",
                        set: "#{singular}_id", with: 'id')
    propagate_id(klass, fk: 'ref_resource_fk', other: 'references.resource_pk',
                        set: 'reference_id', with: 'id')
  end

  def resolve_attributions(klass)
    # [Medium, Article, Trait, Association].each do |klass|
    propagate_id(ContentAttribution, fk: 'content_resource_fk', other: "#{klass.table_name}.resource_pk",
                                     set: 'content_id', with: 'id', poly_type: 'content_type', poly_val: klass)
    # end
  end

  def resolve_attribution_keys
    propagate_id(ContentAttribution, fk: 'attribution_resource_fk', other: 'attributions.resource_pk',
                                     set: 'attribution_id', with: 'id')
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

  def log_err(e)
    puts "GENERAL ERROR"
    # custom exceptions have no backtrace, for some reason:
    @harvest.log('', e: e, cat: :errors, line: @line_num, format: @format)
    @harvest.fail
    raise e
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
    # TODO: Likely other "kinds" of downloads for other kinds of media.
    @harvest.download_all_images
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
    @harvest.convert_trait_units
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

  # TODO: this is a LOUSY place to put the publishing, but it's a real pain to add new steps to harvesting. I'll do it
  # eventually, but not now.
  def complete_harvest_instance
    Publisher.by_resource(@resource, logger: @harvest)
    @harvest.complete
  end

  def each_format(options = {}, &block)
    @harvest.formats.each do |fmt|
      @format = fmt
      fid = @format.id
      unless @formats.key?(fid)
        @formats[fid] = {}
        @file = @format.file
        @formats[fid][:parser] = @format.file_parser
        @formats[fid][:headers] = @formats[fid][:parser].headers
        # If we made it here, the file is parse-able, so we should save the row_sep/line_sep, if different (so we don't
        # have to re-try it in the future):
        @format.update_attribute(:line_sep, @formats[fid][:parser].row_sep) if
          @formats[fid][:parser].row_sep != @format.line_sep
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
        @formats[fid][:parser] = @format.diff_parser
        @formats[fid][:headers] = @format.headers
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
