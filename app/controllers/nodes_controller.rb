class NodesController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @nodes = prep_for_api(@resource.nodes.includes(:scientific_name, :identifiers, :node_ancestors))
    respond_to do |fmt|
      fmt.json {}
      # NOTE: I read that as_json (and to_json) was faster than JBuilder... but that turned out to be false. Keeping for
      # posterity, but: don't use. It's actually slightly *slower*.
      # fmt.json do
      #   render json: {
      #     total_pages: @nodes.total_pages,
      #     current_page: @nodes.current_page,
      #     nodes: @nodes.map { |n| n.as_json }
      #   }.to_json
      # end
    end
  end

  def show
    @node = Node.find(params[:id])
  end

  def search
    @results = Node.search('*', where: { canonical: params[:q] })
  end
end
