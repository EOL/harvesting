class TraitsController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @traits = @resource.traits.primary
                       .includes(:predicate_term, :object_term, :units_term, :statistical_method_term, :sex_term,
                                 :lifestage_term, :node, meta_traits: %i(predicate_term object_term units_term
                                                                         statistical_method_term))
                       .published.page(params[:page] || 1).per(params[:per] || 1000)
    respond_to do |fmt|
      fmt.json {}
    end
  end
end
