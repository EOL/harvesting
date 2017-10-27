class NodesController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @nodes = @resource.nodes.includes(:scientific_name).published.page(params[:page] || 1).per(params[:per] || 5000)
    respond_to do |fmt|
      fmt.json { }
    end
  end

  def show
    @node = Node.find(params[:id])
  end
end
