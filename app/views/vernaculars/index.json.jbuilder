json.total_pages @names.total_pages
json.current_page @names.current_page
json.vernaculars @names do |name|
  json.page_id name.node.page_id
  json.extract! name, *%i(node_resource_pk verbatim language_code_verbatim locality remarks source is_preferred)
  if name.language
    json.language do
      json.extract! name.language, :group_code, :code
    end
  end
end
