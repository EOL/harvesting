class TraitsController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    meta_fields = %i[predicate_term object_term units_term statistical_method_term]
    property_fields = meta_fields + %i[sex_term lifestage_term]
    @traits = prep_for_api(
      @resource .traits.primary.published
     # DELETEME:
     traits = Trait.where(id: ids) .includes(property_fields,
               children: meta_fields,
               occurrence: { occurrence_metadata: property_fields }, # NOTE property_fields, not meta_fields; has sex...
               node: :scientific_name,
               meta_traits: meta_fields)
    )
    respond_to do |fmt|
      fmt.json {}
    end
  end
end
