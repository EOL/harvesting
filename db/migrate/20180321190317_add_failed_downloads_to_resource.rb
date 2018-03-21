class AddFailedDownloadsToResource < ActiveRecord::Migration
  def change
    add_column :resources, :downloaded_media_count, :integer, comment: 'how many images have successfully downloaded.'
    add_column :resources, :failed_downloaded_media_count, :integer,
               comment: 'how many images have NOT successfully downloaded.'
  end
end
