class PublishController < ApplicationController
  def new_traits 
    handle_request(:new_traits)
  end

  def removed_traits
    handle_request(:removed_traits)
  end

  def new_metadata
    handle_request(:new_metadata)
  end

  private
  def handle_request(type)
    diff_method = "#{type}_path"

    respond_to do |fmt|
      fmt.csv do 
        resource = Resource.find(params.require(:resource_id))
        since = params[:since].present? ? params[:since]&.to_i : nil
        diff = TraitDiff.new(resource, since)
        
        if diff.valid?
          path = diff.send(diff_method)

          if path.blank?
            head :no_content
          else
            send_file(path, content_type: 'text/csv')
          end
        else
          head :not_found
        end
      end
    end
  end
end
