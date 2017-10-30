class TraitsController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @traits = prep_for_api(@resource.
                           traits.primary
                           .includes(:predicate_term, :object_term, :units_term, :statistical_method_term, :sex_term,
                                     :lifestage_term, :node, meta_traits: %i(predicate_term object_term units_term
                                                                             statistical_method_term))
                       .published)
    respond_to do |fmt|
      fmt.json {}
    end
  end
end
