class ResourcesController < ApplicationController
  before_action :authenticate_user!, except: [:ping, :index, :show]

  # See your environment config; this action should be ignored by logs.
  def ping
    if ActiveRecord::Base.connection.active?
      render text: 'pong'
    else
      render status: 500
    end
  end

  def index
    params[:per_page] ||= 50
    @resources = Resource.order(:name).includes([:partner])
    @resources = @resources.where(publish_status: Resource.publish_statuses[:published]) unless params[:all]
    params[:per_page] = 15 if request.format.html?
    @resources = prep_for_api(@resources, updated: true)
    respond_to do |fmt|
      fmt.html {}
      fmt.json {}
    end
  end

  def show
    @resource = Resource.find(params[:id])
    @formats = Format.where(resource_id: @resource.id)
    respond_to do |fmt|
      fmt.html do
        @root_nodes = @resource.nodes.published.root.order('canonical, resource_pk').page(params[:page] || 1)
                               .per(params[:per] || 10)
      end
      # TODO: add the "since" param...
      fmt.json {}
    end
  end

  def harvest
    enqueue_harvest
  end

  def re_harvest
    enqueue_harvest(:re)
  end

  def resume_harvest
    enqueue_harvest(:resume)
  end

  def re_download_opendata_harvest
    enqueue_harvest(:re_download_opendata)
  end

  def re_create_tsv
    @resource = Resource.find(params[:resource_id])
    log_auth(@resource)
    @resource.delay(queue: 'harvest').publish
    flash[:notice] = t('resources.flash.re_create_tsv_enqueued')
    redirect_to @resource
  end

  def re_read_xml
    @resource = Resource.find(params[:resource_id])
    log_auth(@resource)
    @resource.re_read_xml
    flash[:notice] = t('resources.flash.re_read_xml')
    redirect_to @resource
  end

  def new
    @resource = Resource.new
    log_auth(@resource)
  end

  def edit
    @resource = Resource.find(params[:id])
    log_auth(@resource)
  end

  def create
    @resource = Resource.new(resource_params)
    log_auth(@resource)

    if @resource.opendata_url
      @resource = Resource::FromOpenData.url(@resource.opendata_url)
      flash[:notice] = I18n.t('resources.flash.imported', name: @resource.name,
                                                          path: resource_path(@resource)).html_safe
      redirect_to @resource
    elsif @resource.save
      flash[:notice] = I18n.t('resources.flash.created', name: @resource.name,
                                                         path: resource_path(@resource)).html_safe
      redirect_to @resource
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render 'new'
    end
  end

  def update
    @resource = Resource.find(params[:id])
    log_auth(@resource)
    if @resource.update(resource_params)
      resp = WebDb.update_resource(@resource)
      flash[:notice] = I18n.t('resources.flash.updated', name: @resource.name, path: resource_path(@resource))
      flash[:notice] += " (#{resp})" unless resp.blank?
      redirect_to @resource
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render 'edit'
    end
  end

  def destroy
    @resource = Resource.find(params[:id])
    log_auth(@resource)
    name = @resource.name
    @resource.destroy
    flash[:notice] = I18n.t('resources.flash.destroyed', name: name)
    redirect_to resources_path
  end

  def unlock
    @resource = Resource.find(params[:resource_id])
    log_auth(@resource)
    @resource.unlock
    flash[:notice] = "It should be unlocked now. You can try re-harvesting or resuming."
    redirect_to resource_path(@resource)
  end

  def remove_content
    @resource = Resource.find(params[:resource_id])
    log_auth(@resource)
    Delayed::Job.enqueue(RemoveContentJob.new(@resource.id))
    flash[:notice] = t('resources.flash.remove_content_enqueued')
    redirect_to @resource
  end

  def kill_workers
    `#{Rails.root}/bin/stop_work`
    `#{Rails.root}/bin/stop_media`
    flash[:notice] = t('resources.flash.killed_workers')
    redirect_to resources_path
  end

  def destroy_harvests
    @resource = Resource.find(params[:resource_id])
    @resource.harvests.destroy_all
    @resource.delete_trait_publish_files
    flash[:notice] = t('resources.flash.destroy_harvests')
    redirect_to resource_path(@resource)
  end

  private

  def enqueue_harvest(type = '')
    @resource = Resource.find(params[:resource_id])
    log_auth(@resource)
    count = Delayed::Job.where(queue: 'harvest', locked_at: nil).count
    type = "#{type}_" unless type.blank?
    @resource.log_info("## HARVEST: type = #{type}-harvest")
    @resource.send("enqueue_#{type}harvest")
    flash[:notice] = t('resources.flash.harvest_enqueued', count: count)
    redirect_to @resource
  end

  def resource_params
    params.require(:resource)
          .permit(:name, :abbr, :pk_url, :opendata_url, :min_days_between_harvests, :harvest_day_of_month, :notes,
                  :harvest_months_json, :auto_publish, :not_trusted, :might_have_duplicate_taxa, :description,
                  :is_browsable, :dataset_rights_holder, :dataset_license_id, :dataset_rights_statement,
                  :classification, :can_perform_trait_diffs)
  end
end
