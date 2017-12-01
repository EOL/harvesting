json.total_pages @traits.total_pages
json.current_page @traits.current_page
json.traits @traits do |trait|
  json.page_id trait.node.page_id
  json.scientific_name trait.node.scientific_name.italicized
  json.resource_pk trait.resource_pk
  json.predicate trait.predicate_term.uri
  json.value_uri trait.object_term.try(:uri)
  json.value_num trait.measurement
  json.value_literal trait.literal
  json.units trait.units_term.try(:uri)
  json.statistical_method trait.statistical_method_term.try(:uri)
  json.sex trait.sex_term.try(:uri)
  json.lifestage trait.lifestage_term.try(:uri)
  json.source trait.source

  json.metadata (trait.meta_traits + trait.children + trait.occurrence.occurrence_metadata).compact do |meta|
    json.predicate meta.predicate_term.try(:uri)
    # NOTE Using if's rather than #&. because we don't want the json to return nil, if missing:
    json.units meta.units_term.try(:uri) if meta.respond_to?(:units_term)
    json.statistical_method meta.statistical_method_term.try(:uri) if meta.respond_to?(:statistical_method_term)
    json.value_uri meta.object_term.try(:uri)
    json.value_num meta.measurement if meta.respond_to?(:measurement)
    json.value_literal meta.literal
    json.sex meta.sex_term.uri if meta.respond_to?(:sex_term) && meta.sex_term
    json.lifestage meta.lifestage_term.uri if meta.respond_to?(:lifestage_term) && meta.lifestage_term
    json.source meta.source if meta.respond_to?(:source)
  end
end
