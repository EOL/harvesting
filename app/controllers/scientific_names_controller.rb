class ScientificNamesController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @names = prep_for_api(@resource.scientific_names.includes(:node, :dataset).published)
    respond_to do |fmt|
      fmt.json { }
    end
  end
end
