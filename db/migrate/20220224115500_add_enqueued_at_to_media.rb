class AddEnqueuedAtToMedia < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :enqueued_at, :datetime, comment: "When the image was added to the delayed job queue"
  end
end
