json.total_pages @nodes.total_pages
json.current_page @nodes.current_page
json.nodes @nodes do |node|
  json.page_id node.page_id
  json.rank node.rank
  json.scientific_name node.scientific_name.verbatim
  json.canonical_form 'TODO'
  json.resource_pk node.resource_pk
  json.source_url URI.escape(@resource.pk_url.gsub('$PK', node.resource_pk))
end
