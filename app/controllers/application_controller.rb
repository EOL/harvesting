class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :null_session

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def prep_for_api(query, opts = {})
    field = opts[:updated] ? 'updated_at' : 'created_at'
    query = query.where(["#{field} > ?", Time.at(params[:since].to_i)]) if params[:since]
    query = query.page(params[:page] || 1).per(params[:per_page] || 1000)
  end

  protected

  def log_auth(what, which = nil)
    log_activity # NOTE we log first, regardless of the results.
    authorize(what, which || :update?)
  end

  def log_activity
    # NOTE: this weird (1..1)[0] syntax is a "performance recommendation" from ruby. [shrug]
    which = caller(1..1)[0]
    which = caller(2..2)[0] if which =~ /log_auth/
    (path, line, method) = which.split(':')
    source = path.split('/').last.sub('_controller.rb', '')
    fn = method[4..-2] # Strip out the "in ``"
    user = current_user&.email || '[ANONYMOUS]'
    ids = params.select { |p| p =~ /id$/ }.to_hash.map { |key, val| "#{key}: #{val}" }
    access_logger.warn("#{user} (#{request.remote_ip}) calling #{source.titleize}Controller##{fn} +#{line} "\
      "{ #{ids.join(', ')} })")
  end

  def access_logger
    return @@access_logger if defined?(@@access_logger)
    @@access_logger = Logger.new(Rails.root.join('log', 'access.log'))
    @@access_logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    @@access_logger
  end

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    user = current_user&.email || '[ANONYMOUS]'
    access_logger.error("#{user} (#{request.remote_ip}) DENIED.")
    redirect_to(request.referrer || root_path)
  end
end
