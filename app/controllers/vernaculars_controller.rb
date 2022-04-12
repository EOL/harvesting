class VernacularsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  
  def index
    @resource = Resource.find(params[:resource_id])
    @names = @resource.vernaculars.includes(:node).harvested.page(params[:page] || 1).per(params[:per] || 1000)
    respond_to do |fmt|
      fmt.json { }
    end
  end
end
