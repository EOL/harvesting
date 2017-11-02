class LanguagesController < ApplicationController
  def show
    @language = Language.find(params[:id])
  end
end
