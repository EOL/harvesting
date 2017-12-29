# DwCA files have a "meta.xml" file describing their contents. We read that once
# (until it changes), and we don't ever need to look again. (Plus we have the
# ability to examine it in the UI.)
class MetaParser
  def self.parse(resource)
    parser = self.new(resource)
    parser.parse
  end

  def initialize(resource)
    # TODO: make it handle gzip.
    # uri = URI.parse(resource.harvest_from)
    # %w(http https).include?(uri.scheme) # Means it's a URL!
    @file = resource.harvest_from
    @resource = resource
  end

  def parse
    doc = File.open(@file) { |f| Nokogiri::XML(f) }
    doc.css("table").each { |tablenode| read_table(tablenode) }
  end

  def read_table(node)
    utf8 = node.attributes["encoding"] and
      node.attributes["encoding"].value == "UTF-8"
    # Yes, we're forcing actual true/false values here, rather than returning
    # any non-nil object to represent True.
    utf8 = utf8 ? true : false
    table = Format.create(
      resource_id: @resource.id,
      header_lines: node.attributes["ignoreHeaderLines"].value.to_i,
      field_sep: node.attributes["fieldsTerminatedBy"].value.gsub('\\\\', '\\'),
      line_sep: node.attributes["linesTerminatedBy"].value.gsub('\\\\', '\\'),
      utf8: utf8
    )
    node.css("files/location").each { |locnode| read_fileloc(table, locnode) }
    node.css("field").each { |fieldnode| read_field(table, fieldnode) }
  end

  def read_fileloc(table, node)
    FileLoc.create(
      table_id: table.id,
      location: node.text
    )
  end

  def read_field(table, node)
    Field.create(
      table_id: table.id,
      position: node.attributes["index"].value,
      term: node.attributes["term"].value
    )
  end
end
