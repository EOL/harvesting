class AddCompilerUriToAssocs < ActiveRecord::Migration[5.2]
  def change
    add_column :assocs, :compiler_uri, :string
  end
end
