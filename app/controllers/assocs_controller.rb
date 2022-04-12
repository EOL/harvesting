class AssocsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  def index
    @resource = Resource.find(params[:resource_id])
    @assocs = prep_for_api(@resource.assocs.harvested
                           .includes(:predicate_term, :sex_term, :lifestage_term, :references, :meta_assocs,
                                     occurrence: { occurrence_metadata: %i[predicate_term object_term] },
                                     node: :scientific_name, target_node: :scientific_name))
    respond_to do |fmt|
      fmt.json {}
    end
  end
end
