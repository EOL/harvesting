class HarvestsController < ApplicationController
  def show
    @harvest = Harvest.find(params[:id])
    @logs = @harvest.hlogs.order('id DESC').page(params[:page]).per(params[:per_page] || 50)
  end
end
