# Refactor of from_meta_xml.rb #import TODO: This class has too much in it. It should really just have the logic to read
# the file and hand back the parsed XML. The logic for creating formats and fields belongs in other classes.
class MetaXml
  attr_reader :warnings

  def initialize(resource)
    @resource = resource
    filename = "#{@resource.path}/meta.xml"
    raise 'Missing meta.xml file' unless File.exist?(filename)

    @doc = File.open(filename) { |f| Nokogiri::XML(f) }
    @warnings = []
    @formats = []
    format_xml = @doc.css('archive table')
    format_xml = @doc.css('archive core') if format_xml.empty?
    format_xml.each do |xml|
      filename = xml.css('location').text
      path = "#{@path}/#{filename}"
      @formats << { filename: filename, path: path.gsub(' ', '\\ '), xml: xml }
    end
  end

  def create_models
    @formats.each do |format|
      parse_xml(format)
      Field.import!(format[:fields])
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
      raise "I cannot determine what #{format[:filename]} represents!"
    end
  end

  def determine_sep(format)
    format[:sep] = YAML.safe_load(%(---\n"#{format[:xml]['fieldsTerminatedBy']}"\n))
  end

  def determine_line_terminator(format)
    format[:lines] = YAML.safe_load(%(---\n"#{format[:xml]['linesTerminatedBy']}"\n))
    # Need to check for those stupid \r line endings that mac editors can use:
    cr_count = `grep -o $'\\r' #{format[:path]} | wc -l`.chomp.to_i
    lf_count = `grep -o $'\\n' #{format[:path]} | wc -l`.chomp.to_i
    format[:lines] = "\r" if lf_count <= 1 && cr_count > 1
    format[:lines] = "\n" if cr_count <= 1 && lf_count > 1
    # (otherwise, trust what the XML file said ... we just USUALLY can't. Ugh.)
  end

  def format_params(format)
    format[:params] = {
      resource_id: @resource.id,
      harvest_id: nil,
      header_lines: format[:xml]['ignoreHeaderLines'],
      data_begins_on_line: format[:xml]['ignoreHeaderLines'],
      file_type: :csv,
      represents: represents,
      get_from: "#{@path}/#{format[:filename]}",
      field_sep: format[:sep],
      line_sep: format[:lines],
      utf8: format[:xml]['encoding'] =~ /^UTF/
    }
  end

  def determine_headers(format)
    format[:headers] = nil
    lines = format[:xml]['ignoreHeaderLines'].to_i
    return if lines.zero?

    format[:headers] = `cat #{format[:path]} | tr "\r" "\n" | head -n #{lines}`.split(format[:sep])
    format[:headers].last.chomp!
  end

  def determine_fields
    format[:fields] = []
    format[:xml].css('field').each do |field|
      insight = field_insight(field)
      format[:fields][insight[:index]] = field_params(insight)
      if insight[:mapping_name] == 'to_ignored'
        @warnings << "(common) IGNORED #{format[:name]} (#{represents}) field header: #{insight[:header_name]} "\
                     "term: #{field['term']}"
      end
    end
  end

  def field_insight(field)
    insight = {}
    insight[:assumption] = MetaXmlField.where(term: field['term'], for_format: represents)&.first
    insight[:mapping_name] = insight[:assumption]&.represents || :to_ignored
    insight[:index] = field['index'].to_i
    insight[:header_name] = format[:headers] ? format[:headers][insight[:index]] : field['term'].split('/').last
    insight
  end

  def field_params(insight)
    {
      format_id: format[:model].id,
      position: insight[:index] + 1, # Looks like position now starts at 1 in the list gem.
      validation: nil, # TODO...
      mapping: Field.mappings[insight[:mapping_name]],
      special_handling: nil, # TODO...
      submapping: determine_submapping(insight[:assumption], insight[:header_name], insight[:mapping_name]),
      expected_header: insight[:header_name],
      unique_in_format: insight[:assumption] ? insight[:assumption].is_unique : false,
      can_be_empty: insight[:assumption] ? !insight[:assumption].is_required : true
    }
  end

  def determine_submapping(insight)
    a_submap = insight[:assumption]&.submapping
    a_submap = nil if a_submap == '0'
    a_submap = insight[:header_name].downcase if insight[:mapping_name] == 'to_nodes_ancestor'
    a_submap
  end

  def show_warnings
    @warnings.each { |warning| puts "!! #{warning}" }
  end
end
