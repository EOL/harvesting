require "open3"

class ResourceHarvester
  attr_accessor :resource, :harvest

  # NOTE: Composition pattern, here. Too much to have in one file:
  include Store::Nodes
  include Store::Media
  include Store::Vernaculars
  include Store::ModelBuilder

  def initialize(resource, harvest = nil)
    @resource = resource
    @previous_harvest = @resource.harvests.completed.last
    @harvest = nil
    @uris = {}
    @formats = {}
    @harvest = harvest
    @converted = {}
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
    # TODO (LOW-PRIO) queue_downloads
    # TODO parse_names
    # TODO match_nodes
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
    each_format do |fmt, parser, headers|
      fields = {}
      expected_by_file = headers.dup
      fmt.fields.each_with_index do |field, i|
        raise Exceptions::ColumnMissing.new(field.expected_header) if
          headers[i].nil?
        raise Exceptions::ColumnMismatch.new("expected '#{field.expected_header}' as column #{i}, but got '#{headers[i]}'") unless
          field.expected_header == headers[i]
        fields[headers[i]] = field
        expected_by_file.delete(headers[i])
      end
      raise Exceptions::ColumnUnmatched.new(expected_by_file.join(",")) if
        expected_by_file.size > 0
      CSV.open(fmt.converted_csv_path, "wb") do |csv|
        parser.rows_as_hashes do |row, line|
          csv_row = []
          headers.each do |header|
            check = fields[header]
            next unless check
            val = row[header]
            if val.blank?
              next if check.can_be_empty?
              fmt.warn("Illegal empty value for #{header}", line)
            end
            if check.must_be_integers?
              unless row[header] =~ /\a[\d,]+\z/m
                fmt.warn("Illegal non-integer for #{header}, got #{val}", line)
              end
            elsif check.must_know_uris?
              unless uri_exists?(val)
                fmt.warn("Illegal unknown URI <#{val}> for #{header}", line)
              end
            end
            csv_row << val
          end
          csv << csv_row
        end
      end
      @converted[fmt.id] = true
      # Write each line to a CSV (no headers)
    end
  end

  def convert
    each_format do |fmt, parser, headers|
      unless @converted[fmt.id]
        CSV.open(fmt.converted_csv_path, "wb") do |csv|
          parser.rows_as_hashes do |row, line|
            csv_row = []
            headers.each do |header|
              csv_row << row[header]
            end
            csv << csv_row
          end
        end
        @converted[fmt.id] = true # Shouldn't need this, but being safe
      end
      cmd = "/usr/bin/sort #{fmt.converted_csv_path} > "\
            "#{fmt.converted_csv_path}_sorted"
      if system(cmd)
        FileUtils.mv("#{fmt.converted_csv_path}_sorted", fmt.converted_csv_path)
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
    each_format do |fmt, parser, headers|
      pn = Pathname.new(fmt.file)
      fmt.update_attribute(:diff, fmt.diff_path) # TODO - meh. Why save this name?
      # YOU WERE HERE - Modify this to ensure that it's reading the
      # converted_csv and doesn't bother with a header.
      other_fmt = @previous_harvest ?
        @previous_harvest.formats.find { |f| f.represents == fmt.represents } :
        nil
      # There's no diff if the previous format failed!
      if other_fmt && File.exist?(other_fmt.converted_csv_path)
        diff(other_fmt, fmt)
      else
        fake_diff_from_nothing(fmt)
      end
    end
  end

  def diff(old_fmt, new_fmt)
    File.unlink(new_fmt.diff) if File.exist?(new_fmt.diff)
    cmd = "/usr/bin/diff #{old_fmt.converted_csv_path} "\
      "#{new_fmt.converted_csv_path} > #{new_fmt.diff}"
    # TODO: We can't trust the exit code! diff exits 0 if the files are the
    # same, and 1 if not.
    system(cmd)
  end

  def fake_diff_from_nothing(fmt)
    system("echo \"0a\" > #{fmt.diff}")
    system("cat #{fmt.file} >> #{fmt.diff}")
    system("echo \".\" >> #{fmt.diff}")
  end

  # read the raw new/updated data into the database, TODO: log curation conflicts
  def store
    # Recall these are in a specific order (and need to be). The assumption here
    # is that the file describing the nodes MUST be first. (It MUST be.)
    gather_nodes
    @ancestors = {}
    each_diff do |fmt, parser, headers|
      fields = build_fields(fmt, headers)
      any_diff = parser.diff_as_hashes(headers) do |row, line_number, diff|
        # Just to give access to the line number elsewhere:
        @line_number = line_number
        # We *could* skip this, but I prefer not to deal with the missing keys.
        @models = { node: nil, parent_node: nil, scientific_name: nil,
          ancestors: [], medium: nil, vernacular: nil }
        begin
          headers.each do |header|
            field = fields[header]
            next if row[header].blank?
            next if field.to_ignored?
            # NOTE: that these methods are defined in the Store::* mixins:
            send(field.mapping, field, row[header])
          end
        rescue => e
          puts "Failed to parse row #{line_number}..."
          debugger
          raise e
        end
        begin
          # NOTE: see Store::ModelBuilder mixin for the methods called here:
          # (Why? Composition.)
          if diff == :removed
            destroy_for_fmt(fmt.model_fks)
          else # new or changed
            build_models(diff, fmt.model_fks)
          end
        rescue => e
          if row.values.compact.size < (row.values.size / 5)
            fmt.warn("Empty row?", line_number)
          else
            puts "Failed to save data from row #{line_number}..."
            puts e.message
            puts e.backtrace[0..10]
            debugger
            raise e
          end
        end
      end
      unless any_diff
        fmt.warn("There were no differences in this file!", 0)
      end
    end
  end

  # NOTE: yes, this could be *quite* large, but I believe memory is fine with a
  # hash of two million (smallish) members, so I'm doing it.
  def gather_nodes
    @nodes = {}
    @resource.nodes.published.find_each do |node|
      @nodes[node.resource_pk] = node
    end
  end

  def build_fields(fmt, headers)
    fields = {}
    fmt.fields.each_with_index do |field, i|
      fields[headers[i]] = field
    end
    fields
  end

  def queue_downloads
  end

  def parse_names
    NameParser.for_resrouce(@resource)
  end

  # match node names against the DWH, store "hints", report on unmatched
  # nodes, consider the effects of curation
  def match_nodes
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
      fid = fmt.id
      unless @formats.has_key?(fid)
        @formats[fid] = {}
        @formats[fid][:parser] = if fmt.excel?
            ExcelParser.new(fmt.file, sheet: fmt.sheet,
              header_lines: fmt.header_lines,
              data_begins_on_line: fmt.data_begins_on_line)
          elsif fmt.csv?
            CsvParser.new(fmt.file, field_sep: fmt.field_sep,
              line_sep: fmt.line_sep, header_lines: fmt.header_lines,
              data_begins_on_line: fmt.data_begins_on_line)
          else
            raise "I don't know how to read formats of #{fmt.file_type}!"
          end
        @formats[fid][:headers] = @formats[fid][:parser].headers
      end
      yield(fmt, @formats[fid][:parser], @formats[fid][:headers])
    end
  end

  # This is very much like #each_format, but reads the diff file and ignores the
  # headers in the file (it uses the DB instead)...
  def each_diff(&block)
    @harvest.formats.each do |fmt|
      fid = "#{fmt.id}_diff".to_sym
      unless @formats.has_key?(fid)
        @formats[fid] = {}
        @formats[fid][:parser] = CsvParser.new(fmt.converted_csv_path)
        @formats[fid][:headers] = fmt.fields.sort_by(&:position).map(&:expected_header)
      end
      yield(fmt, @formats[fid][:parser], @formats[fid][:headers])
    end
  end
end
