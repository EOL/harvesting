json.total_pages @names.total_pages
json.current_page @names.current_page
json.scientific_names @names do |name|
  json.page_id name.node.page_id
  json.is_preferred name.node.scientific_name_id == name.id # TODO: make primary field? Not sure.
  json.node_resource_pk name.node_resource_pk
  json.attribution name.attribution_html
  json.taxonomic_status name.taxonomic_status.try(:downcase)
  json.canonical_form name.canonical_italicized
  json.extract! name, *%i(italicized genus specific_epithet infraspecific_epithet infrageneric_epithet uninomial verbatim authorship publication remarks year hybrid surrogate virus parse_quality)
end
