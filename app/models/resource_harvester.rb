# NOTE: you probably want to look at the .store method.
class ResourceHarvester
  attr_accessor :resource, :harvest, :format, :line_num, :diff, :file, :parser, :headers

  # NOTE: Composition pattern, here. Too much to have in one file:
  include Store::Nodes
  include Store::Media
  include Store::Vernaculars
  include Store::Traits
  include Store::Occurrences
  include Store::ModelBuilder

  def initialize(resource, harvest = nil)
    @resource = resource
    @previous_harvest = @resource.harvests.completed.last
    @harvest = nil
    @uris = {}
    @formats = {}
    @harvest = harvest
    @converted = {}
    # Placeholders to mark where we "currently are":
    @diff = nil
    @line_num = nil
    @format = nil
    @file = nil
    @parser = nil
    @headers = nil
  end

  def harvest
    create_harvest_instance
    fetch
    # TODO: CLEARLY the mkdirs do not belong here. I wasn't sure where would be
    # best. TODO: really this (and the one in format.rb) should be configurable
    Dir.mkdir(Rails.public_path.join("converted_csv")) unless
      Dir.exist?(Rails.public_path.join("converted_csv"))
    validate # TODO: this should include a call to check_consistency
    convert
    # TODO: really this (and the one in format.rb) should be configurable
    Dir.mkdir(Rails.public_path.join("diff")) unless
      Dir.exist?(Rails.public_path.join("converted_csv"))
    delta
    store
    resolve_keys
    # TODO (LOW-PRIO) queue_downloads
    parse_names
    normalize_names
    match_nodes
    # TODO build_ancestry
    # TODO normalize_units
    # TODO (LOW-PRIO) link
    # TODO (LOW-PRIO) calculate_statistics
    complete_harvest_instance
  end

  def create_harvest_instance
    @harvest = @resource.create_harvest_instance
  end

  # grab the file from each format
  def fetch
    Harvest::Fetcher.fetch_format_files(@harvest)
  end

  # validate each file; stop on errors, log warnings...
  def validate
    each_format do
      fields = {}
      expected_by_file = @headers.dup
      @format.fields.each_with_index do |field, i|
        raise Exceptions::ColumnMissing.new(field.expected_header) if
          @headers[i].nil?
        raise Exceptions::ColumnMismatch.new("expected '#{field.expected_header}' as column #{i}, but got '#{@headers[i]}'") unless
          field.expected_header == @headers[i]
        fields[@headers[i]] = field
        expected_by_file.delete(@headers[i])
      end
      raise Exceptions::ColumnUnmatched.new(expected_by_file.join(",")) if
        expected_by_file.size > 0
      @file = @format.converted_csv_path
      CSV.open(@file, "wb") do |csv|
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
      # Write each line to a CSV (no headers)
    end
  end

  def convert
    each_format do
      unless @converted[@format.id]
        @file = @format.converted_csv_path
        CSV.open(@file, "wb") do |csv|
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
      if system(cmd)
        FileUtils.mv("#{@format.converted_csv_path}_sorted", @format.converted_csv_path)
      else
        raise "Failed system call { #{cmd} } #{$?}"
      end
    end
  end

  def uri_exists?(uri)
    return true if @uris.has_key?(uri)
    if Term.where(uri: uri).exists?
      @uris[uri] = true
    else
      false
    end
  end

  # Create deltas from previous harvests (or fake one from "nothing")
  def delta
    each_format do
      pn = Pathname.new(@format.file)
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
  end

  def diff(old_fmt)
    File.unlink(@format.diff) if File.exist?(@format.diff)
    cmd = "/usr/bin/diff #{old_fmt.converted_csv_path} "\
      "#{@format.converted_csv_path} > #{@format.diff}"
    # TODO: We can't trust the exit code! diff exits 0 if the files are the
    # same, and 1 if not.
    system(cmd)
  end

  def fake_diff_from_nothing
    system("echo \"0a\" > #{@format.diff}")
    system("cat #{@format.file} >> #{@format.diff}")
    system("echo \".\" >> #{@format.diff}")
  end

  # read the raw new/updated data into the database, TODO: log curation conflicts
  def store
    # Recall these are in a specific order (and need to be). The assumption here is that files which refer to nodes are
    # read AFTER the nodes file, etc.
    gather_nodes
    @ancestors = {}
    @occurrences = {}
    @terms = {}
    each_diff do
      fields = build_fields
      any_diff = @parser.diff_as_hashes(@headers) do |row|
        # We *could* skip this, but I prefer not to deal with the missing keys.
        @models = { node: nil, parent_node: nil, scientific_name: nil, ancestors: [], medium: nil, vernacular: nil,
                    occurrence: nil, trait: nil }
        begin
          @headers.each do |header|
            field = fields[header]
            next if row[header].blank?
            next if field.to_ignored?
            # NOTE: that these methods are defined in the Store::* mixins:
            send(field.mapping, field, row[header])
          end
        rescue => e
          puts "Failed to parse row #{@line_num}..."
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
          # if row.values.compact.size < (row.values.size / 5)
          #   log_warning("?")
          # else
            puts "Failed to save data from row #{@line_num}..."
            puts e.message
            puts e.backtrace[0..10]
            debugger
            raise e
          # end
        end
      end
      unless any_diff
        log_warning("There were no differences in this file!")
      end
    end
  end

  def resolve_keys
    propagate_id(Occurrence, fk: "node_resource_pk", other: "nodes.resource_pk", set: "node_id", with: "id")
    propagate_id(Trait, fk: "occurrence_resource_pk", other: "occurrences.resource_pk", set: "node_id", with: "node_id")
    # TODO: transfer the sex, lifestage, lat, long, locality, and metadata from occurrences to traits...
    # TODO: associations! Yeesh.
  end

  # I AM NOT A FAN OF SQL... but this is *way* more efficient than alternatives:
  def propagate_id(klass, options = {})
    fk = options[:fk]
    set = options[:set]
    with_field = options[:with]
    (o_table, o_field) = options[:other].split(".")
    sql = "UPDATE `#{klass.table_name}` t JOIN `#{o_table}` o ON (t.`#{fk}` = o.`#{o_field}` AND t.harvest_id = ?) "\
          "SET t.`#{set}` = o.`#{with_field}`"
    clean_execute(klass, [sql, @harvest.id])
  end

  def clean_execute(klass, args)
    clean_sql = klass.send(:sanitize_sql, args)
    klass.connection.execute(clean_sql)
  end

  # NOTE: yes, this could be *quite* large, but I believe memory is fine with a
  # hash of two million (smallish) members, so I'm doing it.
  def gather_nodes
    @nodes = {}
    @resource.nodes.published.find_each do |node|
      @nodes[node.resource_pk] = node
    end
  end

  def build_fields
    fields = {}
    @format.fields.each_with_index do |field, i|
      fields[@headers[i]] = field
    end
    fields
  end

  def queue_downloads
  end

  def parse_names
    NameParser.for_resource(@resource)
  end

  def normalize_names
    @harvest.scientific_names.find_each do |name|
      normal = NormalizedName.first_or_create(string: name.normalized, canonical: name.canonical)
      name.update_attribute(:normalized_name_id, normal.id)
    end
  end

  # match node names against the DWH, store "hints", report on unmatched
  # nodes, consider the effects of curation
  def match_nodes
    # TODO - for now we're faking it entirely with no matching:
    @harvest.nodes.update_all("page_id = id")
  end

  # store ancestry for objects (so we know which pages are affected)
  def build_ancestry
  end

  def normalize_units
  end

  # add links and build links to DOI and the like (and find missing DOIs)
  def link
  end

  # update statistics
  def calculate_statistics
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
        @formats[fid][:parser] = CsvParser.new(@format.converted_csv_path)
        @formats[fid][:headers] = @format.fields.sort_by(&:position).map(&:expected_header)
      end
      @parser = @formats[fid][:parser]
      @headers = @formats[fid][:headers]
      @file = @format.diff
      yield
    end
  end

  def log_warning(msg)
    @format.warn(msg, @line_num)
  end
end
