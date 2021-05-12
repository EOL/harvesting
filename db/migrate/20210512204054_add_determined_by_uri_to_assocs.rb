class AddDeterminedByUriToAssocs < ActiveRecord::Migration[5.2]
  def change
    add_column :assocs, :determined_by_uri, :string
  end
end
