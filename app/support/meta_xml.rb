# Refactor of from_meta_xml.rb #import TODO: This class has too much in it. It should really just have the logic to read
# the file and hand back the parsed XML. The logic for creating formats and fields belongs in other classes.
class MetaXml
  attr_reader :warnings

  class << self
    # e.g.: MetaXml.ignore('http://purl.org/dc/terms/publisher', :media)
    def ignore(uri, format, submapping = '')
      params = {
        "term": uri,
        "for_format": format,
        "represents": 'to_ignored',
        "submapping": submapping,
        "is_unique": false,
        "is_required": false
      }
      MetaXmlField.create(params)
      # This helps to add the ignored field to the meta_analyzed.json
      puts ",\n#{params.to_json.gsub(',', ",\n")}"
    end

    def md5_hash(resource)
      file = MetaXml.filename(resource)
      return 'EMPTY' unless File.exist?(file)
      begin
        `cat #{file} | md5sum`.split.first
      rescue
        'EMPTY'
      end
    end

    def filename(resource)
      "#{resource.path}/meta.xml"
    end
  end

  def initialize(resource)
    @resource = resource
    filename = MetaXml.filename(resource)
    build_log_and_raise 'Missing meta.xml file' unless File.exist?(filename)

    @doc = File.open(filename) { |f| Nokogiri::XML(f) }
    @warnings = []
    @formats = []
    format_xml = @doc.css('archive table')
    format_xml = @doc.css('archive core') if format_xml.empty?
    format_xml.each do |xml|
      filename = xml.css('location').text
      path = "#{@resource.path}/#{filename}"
      @formats << { filename: filename, path: path, xml: xml }
    end
  end

  def create_models
    @formats.each do |format|
      parse_xml(format)
      next if format[:fields].nil? # Skipped format.
      begin
        Field.import!(format[:fields])
      rescue ArgumentError => e
        puts "Unable to add these fields:"
        pp format[:fields]
        build_log_and_raise e
      end
    end
    show_warnings
  end

  def parse_xml(format)
    unless File.exist?(format[:path])
      @warnings << "SKIPPING missing file: #{format[:path]}"
      return
    end
    determine_row_representation(format)
    return if format[:represents] == :skip

    determine_sep(format)
    determine_line_terminator(format)
    format_params(format)
    format[:model] = Format.create!(format[:params])
    determine_headers(format)
    determine_fields(format)
  end

  def determine_row_representation(format)
    format[:represents] = row_type_represents(format)
    if format[:represents] == :skip
      @warnings << "SKIPPING #{format[:xml]['rowType']} config (#{format[:filename]})..."
      return
    end
    format[:represents] ||= row_implied_as(format)
  end

  def row_type_represents(format)
    case format[:xml]['rowType']
    when 'http://rs.tdwg.org/dwc/terms/Taxon'
      :nodes
    when 'http://rs.tdwg.org/dwc/terms/Occurrence'
      :occurrences
    when 'http://rs.tdwg.org/dwc/terms/MeasurementOrFact'
      :measurements
    when 'http://eol.org/schema/reference/Reference'
      :refs
    when 'http://eol.org/schema/agent/Agent'
      :agents
    when 'http://eol.org/schema/media/Document'
      :media
    when 'http://rs.gbif.org/terms/1.0/VernacularName'
      :vernaculars
    when 'http://eol.org/schema/Association'
      :assocs
    when 'http://rs.tdwg.org/dwc/terms/Event'
      :skip
    end
  end

  def row_implied_as(format)
    case format[:filename].downcase
    when /^agent/
      :agents
    when /^tax/
      :nodes
    when /^ref/
      :refs
    when /^med/
      :media
    when /^(vern|common)/
      :vernaculars
    when /occurr/
      :occurrences
    when /assoc/
      :assocs
    when /(measurement|data|fact)/
      :measurements
    when /^events/
      @warnings << 'Ignoring events file.'
    else
      build_log_and_raise "I cannot determine what #{format[:filename]} represents!"
    end
  end

  def determine_sep(format)
    format[:sep] = YAML.safe_load(%(---\n"#{format[:xml]['fieldsTerminatedBy']}"\n))
  end

  def determine_line_terminator(format)
    format[:lines] = YAML.safe_load(%(---\n"#{format[:xml]['linesTerminatedBy']}"\n))
    # Need to check for those stupid \r line endings that mac editors can use:
    path = format[:path].gsub(' ', '\\ ')
    cr_count = `grep -o $'\\r' #{path} | wc -l`.chomp.to_i
    lf_count = `grep -o $'\\n' #{path} | wc -l`.chomp.to_i
    format[:lines] = "\r" if lf_count <= 1 && cr_count > 1
    format[:lines] = "\n" if cr_count <= 1 && lf_count > 1
    # (otherwise, trust what the XML file said ... we just USUALLY can't. Ugh.)
  end

  def format_params(format)
    format[:params] = {
      resource_id: @resource.id,
      header_lines: format[:xml]['ignoreHeaderLines'],
      data_begins_on_line: format[:xml]['ignoreHeaderLines'],
      file_type: :csv,
      represents: format[:represents],
      get_from: "#{@resource.path}/#{format[:filename]}",
      field_sep: format[:sep],
      line_sep: format[:lines],
      utf8: format[:xml]['encoding'] =~ /^UTF/
    }
  end

  def determine_headers(format)
    format[:headers] = nil
    lines = format[:xml]['ignoreHeaderLines'].to_i
    return if lines.zero?

    format[:headers] = `cat #{format[:path].gsub(' ', '\\ ')} | tr "\r" "\n" | head -n #{lines}`.split(format[:sep])
    format[:headers].last.chomp!
  end

  def determine_fields(format)
    format[:fields] = []
    format[:xml].css('field').each do |field|
      insight = field_insight(field, format)
      format[:fields][insight[:index]] = field_params(insight, format)
      if insight[:mapping_name] == 'to_ignored'
        @warnings << "(common) IGNORED #{format[:name]} (#{format[:represents]}) field header: #{insight[:header_name]} "\
                     "term: #{field['term']}"
      end
    end
    build_log_and_raise "Missing a field definition, check that your indexes start at 0" if
      format[:fields].any?(nil)
  end

  def field_insight(field, format)
    insight = { term: field['term'], for_format: format[:represents] }
    insight[:assumption] = MetaXmlField.where(term: field['term'], for_format: format[:represents])&.first
    build_log_and_raise %Q(I don't know how to handle a meta.xml field of type "#{field['term']}" for format #{format[:represents]}!) if
      insight[:assumption].nil?

    insight[:mapping_name] = insight[:assumption]&.represents || :to_ignored
    insight[:index] = field['index'].to_i
    insight[:header_name] = format[:headers].nil? ?
      field['term'].split('/').last :
      format[:headers][insight[:index]]
    insight
  end

  def build_log_and_raise(message)
    @resource&.log_error(message)
    raise message
  end

  def field_params(insight, format)
    {
      format_id: format[:model].id,
      position: insight[:index] + 1, # Looks like position now starts at 1 in the list gem.
      validation: nil, # TODO...
      mapping: Field.mappings[insight[:mapping_name]],
      special_handling: nil, # nothing, by default...
      submapping: determine_submapping(insight),
      expected_header: insight[:header_name],
      unique_in_format: insight[:assumption] ? insight[:assumption].is_unique : false,
      can_be_empty: insight[:assumption] ? !insight[:assumption].is_required : true
    }
  end

  def determine_submapping(insight)
    submap = insight[:assumption]&.submapping
    submap = nil if submap == '0'
    submap = insight[:header_name].downcase if insight[:mapping_name] == 'to_nodes_ancestor'
    if insight[:mapping_name] == 'to_nodes_ancestor'
      if insight[:header_name].nil?
        build_log_and_raise 'I have a node-ancestor field that I cannot find a taxonomic level for. '\
              "Missing an index or term: #{insight.inspect}"
      end
      submap = insight[:header_name].downcase
    end
    submap
  end

  def show_warnings
    @warnings.each { |warning| puts "!! #{warning}" }
  end
end
