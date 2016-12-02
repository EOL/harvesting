class ResourceHarvester
  attr_accessor :resource, :harvest

  # NOTE: I'll make this "classy" later; for now I just want to read in our test
  # file and "feel out" how the class should actually work.
  def initialize(resource)
    @resource = resource
    @harvest = nil
  end

  def start
    create_harvest_instance
    fetch
    delta
    store
    check_consistency
    queue_downloads
    parse_names
    match_nodes
    build_ancestry
    normalize_units
    link
    index_and_calculate_statistics
    complete_harvest_instance
  end

  def create_harvest_instance
    @harvest = Harvest.create(resource_id: resource.id)
    resource.formats.each { |fmt| fmt.copy_to_harvest(@harvest) }
  end

  # grab the file from each format
  def fetch
    @harvest.formats.each do |fmt|
      # TODO ... I don't care right now. :)
    end
  end

  # validate each file; stop on errors, log warnings...
  def validate
    @harvest.formats.each do |fmt|
      # TODO: for now, pretending we only read Excel files! We will want to
      # abstract this and move it.
      parser = ExcelParser.new(fmt.file, sheet: fmt.sheet,
        header_lines: fmt.header_lines)
      headers = parser.headers
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
      # parser.rows_as_hashes do |row_hash|
      #   headers.each do |header|
      #     ...
      #   end
      # end
    end
  end

  # check for deltas from previous harvests (if any)
  def delta
  end

  # read the raw new/updated data into the database, log curation conflicts
  def store
  end

  # Check for ID consistency of the new/updated data (missing and unused IDs)
  def check_consistency
  end

  # queue downloads of new/updated media
  def queue_downloads
  end

  # parse names
  def parse_names
  end

  # match node names against the DWH, store "hints", report on unmatched
  # nodes, consider the effects of curation
  def match_nodes
  end

  # store ancestry for objects (so we know which pages are affected)
  def build_ancestry
  end

  # normalize trait units
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
  end
end
