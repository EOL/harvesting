class AddDeterminedByUriToTraits < ActiveRecord::Migration[5.2]
  def change
    add_column :traits, :determined_by_uri, :string
  end
end
