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

  def new
    @resource = Resource.new
  end

  def create
    @resource = Resource.new(resource_params)
    if @resource.save
      flash[:notice] = I18n.t("resources.flash.created", name: @resource.name,
        path: resource_path(@resource)).html_safe
      redirect_to @resource
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render "new"
    end
  end

private

  def resource_params
    params.require(:resource).permit(:name, :abbr, :pk_url,
      :min_days_between_harvests, :harvest_day_of_month, :harvest_months_json,
      :auto_publish, :not_trusted, :might_have_duplicate_taxa)
  end
end
