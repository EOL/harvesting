class AddSourceToOccMeta < ActiveRecord::Migration
  def change
    add_column :occurrence_metadata, :source, :text
  end
end
