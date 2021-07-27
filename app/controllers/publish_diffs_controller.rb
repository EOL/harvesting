class PublishDiffsController < ApplicationController
  def show
    respond_to do |fmt|
      fmt.json do
        resource = Resource.find(params.require(:resource_id))
        since = params.require(:since).to_i

        diff = PublishDiff.since(resource, since)

        if diff.pending?
          diff.perform_with_delay

          render json: {
            status: 'pending'
          }
        elsif diff.completed?
          render json: {
            status: 'completed',
            new_traits_path: diff.new_traits_path,
            removed_traits_path: diff.removed_traits_path,
            new_metadata_path: diff.new_metadata_path,
            remove_all_traits: diff.remove_all_traits?
          }
        else
          render json: {
            status: diff.status
          }
        end
      end
    end
  end
end
