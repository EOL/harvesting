class LanguagesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  def show
    @language = Language.find(params[:id])
  end
end
