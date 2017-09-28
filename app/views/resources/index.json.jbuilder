json.total_pages @resources.total_pages
json.current_page @resources.current_page
json.resources @resources do |resource|
  json.extract! resource, *%i(id nodes_count name abbr description notes is_browsable)
  json.node_source_url_template resource.pk_url
  json.content_trusted_by_default !resource.not_trusted?
  json.has_duplicate_nodes !resource.might_have_duplicate_taxa?
  json.partner resource.partner do |partner|
    json.extract! partner, *%i(id name acronym short_name url description links_json)
  end
end
