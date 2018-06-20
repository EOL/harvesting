class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :null_session

  before_action :underscore_params!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def prep_for_api(query, opts = {})
    field = opts[:updated] ? 'updated_at' : 'created_at'
    query = query.where(["#{field} > ?", Time.at(params[:since].to_i)]) if params[:since]
    query = query.page(params[:page] || 1).per(params[:per_page] || 1000)
  end

  private

  def underscore_params!
    params.deep_transform_keys!(&:underscore)
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || root_path)
  end
end
