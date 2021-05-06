class AddContributorUriToTraits < ActiveRecord::Migration[5.2]
  def change
    add_column :traits, :contributor_uri, :string
  end
end
