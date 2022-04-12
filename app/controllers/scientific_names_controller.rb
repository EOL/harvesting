class ScientificNamesController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @resource = Resource.find(params[:resource_id])
    @names = prep_for_api(@resource.scientific_names.includes(:node, :dataset).harvested)
    respond_to do |fmt|
      fmt.json { }
    end
  end
end
