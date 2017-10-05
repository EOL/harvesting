class MediaController < ApplicationController
  def show
    @medium = Medium.find(params[:id])
  end
end
