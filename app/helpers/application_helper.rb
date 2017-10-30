module ApplicationHelper
  def prep_for_api(query)
    query = query.where(["created_at > ?", Time.at(params[:since].to_i)]) if params[:since]
    query = query.page(params[:page] || 1).per(params[:per] || 1000)
  end
end
