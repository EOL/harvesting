json.total_pages @resources.total_pages
json.current_page @resources.current_page
json.resources @resources do |resource|
  json.extract! resource, *%i(id nodes_count name abbr description notes is_browsable opendata_url)
  json.node_source_url_template resource.pk_url
  json.has_duplicate_nodes !resource.might_have_duplicate_taxa?
  if partner = resource.partner
    json.partner do |json|
      json.extract! partner, *%i(id name abbr short_name homepage_url description links_json)
    end
  end
end
