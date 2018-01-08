json.total_pages @nodes.total_pages
json.current_page @nodes.current_page
json.nodes @nodes do |node|
  json.extract! node, *%i(page_id parent_resource_pk in_unmapped_area resource_pk landmark rank source_url ancestors)
  json.scientific_name node.scientific_name&.normalized || node.scientific_name&.verbatim
  json.canonical_form node.scientific_name.canonical
  json.identifiers node.identifiers do |ider|
    json.extract! ider, :identifier
  end
end
