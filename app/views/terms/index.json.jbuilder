json.total_pages @terms.total_pages
json.current_page @terms.current_page
json.terms @terms do |term|
  json.extract! term, *%i[id uri name definition comment attribution is_hidden_from_overview is_hidden_from_glossary
    created_at updated_at ontology_information_url ontology_source_url is_text_only is_verbatim_only position used_for]
end
