class MediaController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  def index
    @resource = Resource.find(params[:resource_id])
    @media = prep_for_api(@resource.media.includes(:node, :license).harvested)
    respond_to do |fmt|
      fmt.json {}
    end
  end

  def show
    @medium = Medium.find(params[:id])
  end
end
