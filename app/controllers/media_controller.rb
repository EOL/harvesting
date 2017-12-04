class MediaController < ApplicationController
  def index
    @resource = Resource.find(params[:resource_id])
    @media = prep_for_api(@resource.media.includes(:node, :license).published)
    respond_to do |fmt|
      fmt.json {}
    end
  end

  def show
    @medium = Medium.find(params[:id])
  end
end
