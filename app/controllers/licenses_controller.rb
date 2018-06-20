class LicensesController < ApplicationController
  before_action :authenticate_user!
  def show
    @license = License.find(params[:id])
  end
end
