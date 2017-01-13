class ResourcesController < ApplicationController
  def index
    @resources = Resource.order(:name).page(params[:page]).
      per(params[:per_page] || 50)
  end

  def show
    @resource = Resource.find(params[:id])
    @formats = Format.where(resource_id: @resource.id).abstract
    @root_nodes = @resource.nodes.published.root.order(:name_verbatim).page(1).per(10)
  end
end
