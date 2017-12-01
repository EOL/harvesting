class TraitsController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    # NOTE: you may want to add to these terms later!
    meta_fields = %i[predicate_term object_term units_term statistical_method_term]
    property_fields = meta_fields + %i[sex_term lifestage_term]
    @traits = prep_for_api(
      @resource .traits.primary.published
                .includes(property_fields,
                          children: meta_fields,
                          # NOTE property_fields, not meta_fields; has sex, lifestage, etc...
                          occurrence: { occurrence_metadata: property_fields },
                          node: :scientific_name,
                          meta_traits: meta_fields)
    )
    respond_to do |fmt|
      fmt.json {}
    end
  end
end
