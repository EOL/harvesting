json.total_pages @nodes.total_pages
json.current_page @nodes.current_page
json.nodes @nodes do |node|
  json.page_id node.page_id
  json.rank node.rank.try(:downcase)
  json.parent_resource_pk node.parent_resource_pk
  json.scientific_name node.scientific_name.normalized
  json.canonical_form node.scientific_name.canonical
  json.resource_pk node.resource_pk
  json.source_url URI.escape(@resource.pk_url.gsub('$PK', node.resource_pk))
end
