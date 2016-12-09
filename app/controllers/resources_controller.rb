class ResourcesController < ApplicationController
  def show
    @resource = Resource.find(params[:id])
    @formats = Format.where(resource_id: @resource.id).abstract
  end
end
