class FormatsController < ApplicationController
  def show
    @format = Format.find(params[:id])
  end
end
