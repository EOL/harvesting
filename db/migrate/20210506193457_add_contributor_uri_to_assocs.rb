class AddContributorUriToAssocs < ActiveRecord::Migration[5.2]
  def change
    add_column :assocs, :contributor_uri, :string
  end
end
