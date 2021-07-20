class PublishController < ApplicationController
  def new_traits 
    respond_to do |fmt|
      fmt.csv do 
        resource = Resource.find(params.require(:resource_id))
        since = params.require(:since).to_i
        diff = TraitDiff.new(resource, since)
        send_file(diff.new_traits_path, content_type: 'text/csv')
      end
    end
  end

  def removed_traits
  end

  def new_metadata
  end
end
