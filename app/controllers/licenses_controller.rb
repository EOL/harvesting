class LicensesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  def show
    @license = License.find(params[:id])
  end
end
