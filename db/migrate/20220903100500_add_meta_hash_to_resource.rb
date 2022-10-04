# 20220903100500
class AddMetaHashToResource < ActiveRecord::Migration[5.2]
  def change
    add_column :resources, :meta_hash, :string, limit: 32, null: true, default: nil
  end
end
