class HarvestsController < ApplicationController
  def show
    @harvest = Harvest.find(params[:id])
    # @logs = @harvest.hlogs.order('id DESC').page(params[:page]).per(params[:per_page] || 50)

    @logs = File.exist?(@harvest.resource.process_log_path) ?
      File.readlines(@harvest.resource.process_log_path) :
      []
  end

  def destroy
    authenticate_user!
    @harvest = Harvest.find(params[:id])
    resource = @harvest.resource
    @harvest.destroy
    flash[:notice] = t('harvests.flash.destroyed')
    redirect_to resource
  end
end
