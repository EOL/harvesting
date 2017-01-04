require "open3"

class ResourceHarvester
  attr_accessor :resource, :harvest

  # NOTE: Composition pattern, here. Too much to have in one file:
  include Store::Nodes
  include Store::Media
  include Store::Vernaculars
  include Store::ModelBuilder

  # NOTE: I'll make this "classy" later; for now I just want to read in our test
  # file and "feel out" how the class should actually work.
  def initialize(resource)
    @resource = resource
    @harvest = nil
    @uris = {}
    @formats = {}
  end

  def start
    create_harvest_instance
    fetch
    validate
    delta
    store
    check_consistency
    # TODO queue_downloads
    parse_names
    match_nodes
    build_ancestry
    normalize_units
    # TODO link
    # TODO index_and_calculate_statistics
    complete_harvest_instance
  end

  def create_harvest_instance
    @harvest = @resource.create_harvest_instance
  end

  # grab the file from each format
  def fetch
    @harvest.formats.each do |fmt|
      # TODO ... I don't care right now. :)
      fmt.file = fmt.get_from
    end
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
      parser.rows_as_hashes do |row, line|
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
        end
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

  # check for deltas from previous harvests (if any)
  def delta
    # TODO: I don't want to tackle this on the first pass; I will come back to
    # it.
    raise "Unimplemented"
  end

  # read the raw new/updated data into the database, TODO: log curation conflicts
  def store
    # Recall these are in a specific order (and need to be). The assumption here
    # is that the file describing the nodes MUST be first. (It MUST be.)
    @nodes = {}
    @ancestors = {}
    each_format do |fmt, parser, headers|
      fields = build_fields(fmt, headers)
      parser.rows_as_hashes do |row, line|
        # We *could* skip this, but I prefer not to deal with the missing keys.
        @models = { node: nil, parent_node: nil, scientific_name: nil,
          ancestors: [], medium: nil, vernacular: nil }
        begin
          headers.each do |header|
            field = fields[header]
            next if row[header].blank?
            next if field.to_ignored?
            # NOTE: that these methods are defined in the Harvest::* mixins:
            send(field.mapping, field, row[header])
          end
        rescue => e
          puts "Failed to parse row #{line}..."
          debugger
          raise e
        end
        begin
          # NOTE: see Store::ModelBuilder mixin for this (Composition):
          build_models
        rescue => e
          if row.values.compact.size < (row.values.size / 5)
            fmt.warn("Empty row?", line)
          else
            puts "Failed to save data from row #{line}..."
            debugger
            raise e
          end
        end
      end
    end
  end

  def build_fields(fmt, headers)
    fields = {}
    fmt.fields.each_with_index do |field, i|
      fields[headers[i]] = field
    end
    fields
  end

  def check_consistency
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

  # index and update statistics
  def index_and_calculate_statistics
  end

  # send notifications and finish up the instance:
  def complete_harvest_instance
    @harvest.update_attribute(:completed_at, Time.now)
  end
end
