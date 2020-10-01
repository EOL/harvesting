json.total_pages @assocs.total_pages
json.current_page @assocs.current_page
json.assocs @assocs.select { |a| a.node && a.target_node } do |assoc|
  json.page_id assoc.node.page_id
  json.scientific_name assoc.node.scientific_name.italicized
  json.object_page_id assoc.target_node.page_id
  json.target_scientific_name assoc.target_node.scientific_name.italicized
  json.eol_pk "R#{assoc.resource_id}-PK#{assoc.id}"
  json.resource_pk assoc.resource_pk
  json.predicate assoc.predicate_term_uri
  json.sex assoc.sex_term.try(:uri)
  json.lifestage assoc.lifestage_term.try(:uri)
  json.source assoc.source

  json.metadata (assoc.meta_assocs + assoc.references + assoc.occurrence.occurrence_metadata).compact do |meta|
    meta_data_to_json(json, meta)
  end
end
