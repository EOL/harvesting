class LanguagesController < ApplicationController
  before_action :authenticate_user!
  def show
    @language = Language.find(params[:id])
  end
end
