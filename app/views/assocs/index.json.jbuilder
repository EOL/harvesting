json.total_pages @assocs.total_pages
json.current_page @assocs.current_page
json.assocs @assocs do |assoc|
  json.page_id assoc.node.page_id
  json.scientific_name assoc.node.scientific_name.italicized
  json.target_page_id assoc.target_node.page_id
  json.target_scientific_name assoc.target_node.scientific_name.italicized
  json.resource_pk assoc.resource_pk
  json.predicate assoc.predicate_term.uri
  json.sex assoc.sex_term.try(:uri)
  json.lifestage assoc.lifestage_term.try(:uri)
  json.source assoc.source

  json.metadata (assoc.meta_assocs + assoc.references + assoc.occurrence.occurrence_metadata).compact do |meta|
    json.eol_pk "#{meta.class.name}-#{meta.id}"
    if meta.is_a?(Reference)
      # TODO: we should probably make this URI configurable:
      json.predicate 'http://eol.org/schema/reference/referenceID'
      body = meta.body
      body += " <a href='#{meta.url}'>link</a>" unless meta.url.blank?
      body += " #{meta.doi}" unless meta.doi.blank?
      json.value_literal body
    else
      json.predicate meta.predicate_term.try(:uri)
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
end
