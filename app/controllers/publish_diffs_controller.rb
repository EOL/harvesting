class PublishDiffsController < ApplicationController
  PUBLIC_PATH = Rails.root.join('public')
  
  def show
    respond_to do |fmt|
      fmt.json do
        resource = Resource.find(params.require(:resource_id))
        since = params[:since]&.to_i

        diff = PublishDiff.since(resource, since)

        if diff.completed?
          render json: {
            status: 'completed',
            new_traits_path: relpath(diff.new_traits_path),
            removed_traits_path: relpath(diff.removed_traits_path),
            new_metadata_path: relpath(diff.new_metadata_path),
            remove_all_traits: diff.remove_all_traits?
          }
        else
          if diff.pending?
            diff.update!(status: :enqueued)
            diff.perform_with_delay
          end

          render json: {
            status: diff.status
          }
        end
      end
    end
  end

  private
  def relpath(path_str)
    path_str.nil? ? nil : '/' + Pathname.new(path_str).relative_path_from(PUBLIC_PATH).to_s
  end
end
