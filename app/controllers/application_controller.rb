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

  protected

  def access_logger
    @@my_logger ||= Logger.new(Rails.root.join('log', 'access.log'))
  end

  def log_activity
    (path, line, method) = caller.first.split(':')
    source = path.split('/').last.sub('_controller.rb', '')
    fn = method[4..-2] # Strip out the "in ``"
    user = current_user&.email || "[ANONYMOUS]"
    ids = params.select { |p| p =~ /id$/ }.map { |key, val| "#{key}: #{val}" }
    access_logger.warn("#{user} (#{request.remote_ip}) calling #{source.titleize}Controller##{fn} +#{line} "\
      "{ #{ids.join(', ')} })")
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
