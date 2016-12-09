class HarvestsController < ApplicationController
  def show
    @harvest = Harvest.find(params[:id])
  end
end
