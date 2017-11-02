class NodesController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @nodes = prep_for_api(@resource.nodes.includes(:scientific_name, :identifiers, :node_ancestors))
    respond_to do |fmt|
      fmt.json { }
    end
  end

  def show
    @node = Node.find(params[:id])
  end
end
