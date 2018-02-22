class TraitsController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    # NOTE: you may want to add to these terms later!
    simple_meta_fields = %i[predicate_term object_term]
    meta_fields = simple_meta_fields + %i[units_term statistical_method_term]
    property_fields = meta_fields + %i[sex_term lifestage_term references]
    @traits = prep_for_api(
      @resource.traits.primary.published.matched
               .includes(property_fields,
                         children: meta_fields,
                         occurrence: { occurrence_metadata: simple_meta_fields },
                         node: :scientific_name,
                         meta_traits: meta_fields)
    )
    respond_to do |fmt|
      fmt.json { render 'index', traits: @traits }
    end
  end
end
