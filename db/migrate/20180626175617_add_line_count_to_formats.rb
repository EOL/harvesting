class AddLineCountToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :line_count, :integer,
               comment: 'Number of lines read when the format was created (only applies when harvest_id IS NULL)'
  end
end
