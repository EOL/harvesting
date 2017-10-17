class MediaController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @media = @resource.media.includes(:node).published.page(params[:page] || 1).per(params[:per] || 10)
    respond_to do |fmt|
      fmt.json { }
    end
  end

  def show
    @medium = Medium.find(params[:id])
  end
end
