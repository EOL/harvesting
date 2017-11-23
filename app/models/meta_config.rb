# Read a meta.xml config file and create the resource file formats.
class MetaConfig
  attr_accessor :resource, :path, :doc

  def self.import(path, resource = nil)
    new(path, resource).import
  end

  def initialize(path, resource = nil)
    @path = path
    @resource = resource || Resource.create
  end

  def import
    filename = "#{@path}/meta.xml"
    return 'Missing meta.xml file' unless File.exist?(filename)
    @doc = File.open(filename) { |f| Nokogiri::XML(f) }
    debugger
    tables = @doc.css('archive table')
    formats = []
    tables.each do |table|
      table_name = table.css("files location").text
      # TODO: :attributions, :articles, :images, :js_maps, :links, :maps, :sounds, :videos
      reps =
        case table['rowType']
        when "http://rs.tdwg.org/dwc/terms/Taxon"
          :nodes
        when "http://rs.tdwg.org/dwc/terms/Occurrence"
          :occurrences
        when "http://rs.tdwg.org/dwc/terms/MeasurementOrFact"
          :measurements
        when "http://eol.org/schema/reference/Reference"
          :refs
        when "http://eol.org/schema/agent/Agent"
          :agents
        when "http://eol.org/schema/media/Document"
          :media
        when "http://rs.gbif.org/terms/1.0/VernacularName"
          :vernaculars
        when "http://eol.org/schema/Association"
          :assocs
        end
      reps ||=
        case table_name.downcase
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
        else
          raise "I cannot determine what #{table_name} represents!"
        end
      fmt = Format.create!(
        resource_id: @resource.id,
        harvest_id: nil,
        header_lines: table['ignoreHeaderLines'],
        data_begins_on_line: table['ignoreHeaderLines'],
        file_type: :csv,
        represents: reps,
        get_from: "#{@path}/#{table_name}",
        field_sep: table['fieldsTerminatedBy'],
        line_sep: table['linesTerminatedBy'],
        utf8: table['encoding'] =~ /^UTF/
      )
      fields = []
      table.css('field').each do |field|

      end
    end
  end
end
