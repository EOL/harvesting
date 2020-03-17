class AddSourceToOccMeta < ActiveRecord::Migration[4.2]
  def change
    add_column :occurrence_metadata, :source, :text
  end
end
