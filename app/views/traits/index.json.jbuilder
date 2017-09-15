json.total_pages @traits.total_pages
json.current_page @traits.current_page
json.traits @traits do |trait|
  json.page_id trait.node.page_id
  json.resource_id trait.resource_id
  json.resource_pk trait.resource_pk
  json.predicate trait.predicate_term.uri
  json.association trait.object_node_id
  json.value_uri trait.object_term.try(:uri)
  json.value_num trait.measurement
  json.value_literal trait.literal
  json.units trait.units_term.try(:uri)
  json.statistical_method trait.statistical_method_term.try(:uri)
  json.sex trait.sex_term.try(:uri)
  json.lifestage trait.lifestage_term.try(:uri)
  json.source trait.source

  json.metadata trait.meta_traits do |meta|
    json.predicate meta.predicate_term.try(:uri)
    json.units meta.units_term.try(:uri)
    json.statistical_method meta.statistical_method_term.try(:uri)
    json.value_uri meta.object_term.try(:uri)
    json.value_num meta.measurement
    json.value_literal meta.literal
    json.source meta.source
  end
end
