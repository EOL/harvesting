json.total_pages @traits.total_pages
json.current_page @traits.current_page
json.traits(@traits.reject { |t| t.node.page_id.nil? }) do |trait|
  json.page_id trait.node.page_id
  json.scientific_name trait.node.scientific_name.italicized
  json.eol_pk "R#{trait.resource_id}-PK#{trait.id}"
  json.resource_pk trait.resource_pk
  json.predicate trait.predicate_term_uri
  json.value_uri trait&.object_term_uri
  json.measurement trait.measurement
  json.literal trait.literal
  json.units trait&.units_term_uri
  json.statistical_method trait&.statistical_method_term_uri
  json.sex trait&.sex_term_uri
  json.lifestage trait&.lifestage_term_uri
  json.source trait.source

  json.metadata (trait.meta_traits + trait.references + trait.children + trait.occurrence.occurrence_metadata).compact do |meta|
    meta_data_to_json(json, meta)
  end
end
