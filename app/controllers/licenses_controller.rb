class LicensesController < ApplicationController
  def show
    @license = License.find(params[:id])
  end
end
