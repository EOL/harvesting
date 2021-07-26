class CreatePublishDiffs < ActiveRecord::Migration[5.2]
  def change
    create_table :publish_diffs do |t|
      t.integer :resource_id
      t.integer :t1
      t.integer :t2
      t.integer :status

      t.timestamps
    end
  end
end
