class HarvestsController < ApplicationController
  def show
    @harvest = Harvest.find(params[:id])

    @path = @harvest.resource.process_log_path
    @logs = File.exist?(@path) ?
      File.readlines(@path) :
      []
    @lines = @logs&.size || 0
    @logs = @logs[-1000..-1]
  end

  def destroy
    authenticate_user!
    @harvest = Harvest.find(params[:id])
    resource = @harvest.resource

    @harvest.destroy

    if @harvest.completed_at.present? && resource.can_perform_trait_diffs?
      resource.update!(can_perform_trait_diffs: false)
      flash[:notice] = t('harvests.flash.destroyed_cant_perform_trait_diffs')
    else
      flash[:notice] = t('harvests.flash.destroyed')
    end

    redirect_to resource
  end
end
