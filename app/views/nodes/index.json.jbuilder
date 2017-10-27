json.total_pages @nodes.total_pages
json.current_page @nodes.current_page
json.nodes @nodes do |node|
  json.extract! node, *%i(page_id parent_resource_pk in_unmapped_area resource_pk)
  json.rank node.rank.try(:downcase)
  json.scientific_name node.scientific_name.normalized
  json.canonical_form node.scientific_name.canonical
  json.source_url URI.escape(@resource.pk_url.gsub('$PK', node.resource_pk))
  json.identifiers node.identifiers do |ider|
    json.extract! ider, :identifier
  end
  json.ancestors node.ancestors.map(&:resource_pk)
end
