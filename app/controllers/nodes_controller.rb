class NodesController < ApplicationController
  def show
    @node = Node.find(params[:id])
  end
end
