json.nodes @nodes do |node|
  json.page_id node.page_id
  json.rank node.rank
  json.scientific_name node.scientific_name.verbatim # Really, this is TODO
  json.canonical_form node.scientific_name.verbatim
  json.resource_pk node.resource_pk
  json.source_url "TODO"
end
