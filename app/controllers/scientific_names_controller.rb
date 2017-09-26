class ScientificNamesController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @names = @resource.scientific_names.includes(:node).published.page(params[:page] || 1).per(params[:per] || 1000)
    respond_to do |fmt|
      fmt.json { }
    end
  end
end