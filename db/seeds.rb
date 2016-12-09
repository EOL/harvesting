resource = Resource.where(name: "Smithsonian").first_or_create do |r|
  r.site_id = 1
  r.site_pk = "SI"
  r.position = 1
  r.name = "Smithsonian"
  r.abbr = "SI"
end

fmt = Format.where(
      resource_id: resource.id,
      represents: Format.represents[:nodes]).
    abstract.
    first_or_create do |f|
  f.resource_id = resource.id
  f.represents = Format.represents[:nodes]
  f.position = 1
  f.file_type = Format.file_types[:csv]
  f.get_from = "http://example.com/path/to_file.csv"
end

Field.where(format_id: fmt.id, position: 1).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 1
  f.validation = Field.validations[:must_be_integers]
  f.expected_header = "TID"
  f.map_to_table = "nodes"
  f.map_to_field = "resource_pk"
  f.unique_in_format = true
  f.can_be_empty = false
end

Field.where(format_id: fmt.id, position: 2).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 2
  f.expected_header = "Kingdom"
  f.map_to_table = "scientific_names"
  f.map_to_field = "verbatim"
  f.mapping = "kingdom"
end

Field.where(format_id: fmt.id, position: 3).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 3
  f.expected_header = "SciName"
  f.map_to_table = "scientific_names"
  f.map_to_field = "verbatim"
  f.can_be_empty = false
end

resource.create_harvest_instance unless resource.harvests.count > 0
