class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :null_session
  before_action :underscore_params!

  def underscore_params!
    params.deep_transform_keys!(&:underscore)
  end

  def prep_for_api(query, opts = {})
    field = opts[:updated] ? 'updated_at' : 'created_at'
    query = query.where(["#{field} > ?", Time.at(params[:since].to_i)]) if params[:since]
    query = query.page(params[:page] || 1).per(params[:per_page] || 1000)
  end
end
