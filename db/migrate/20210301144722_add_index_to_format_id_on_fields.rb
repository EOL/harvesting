class AddIndexToFormatIdOnFields < ActiveRecord::Migration[5.2]
  def change
    add_index :fields, :format_id
    add_index :fields, [:format_id, :position], name: "IndexByFormatAndPosition"
  end
end
