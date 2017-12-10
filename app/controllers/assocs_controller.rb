class AssocsController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])

    @assocs = prep_for_api(@resource.assocs.published
                           .includes(:predicate_term, :sex_term, :lifestage_term,
                                     assocs_references: :reference,
                                     occurrence: { occurrence_metadata: %i[predicate_term object_term] },
                                     node: :scientific_name, target_node: :scientific_name,
                                     meta_assocs: %i[predicate_term object_term units_term statistical_method_term]))
    respond_to do |fmt|
      fmt.json {}
    end
  end
end
