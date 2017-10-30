class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :underscore_params!

  def underscore_params!
    params.deep_transform_keys!(&:underscore)
  end

  def prep_for_api(query)
    query = query.where(["created_at > ?", Time.at(params[:since].to_i)]) if params[:since]
    query = query.page(params[:page]).per(params[:per_page] || 1000)
  end
end
