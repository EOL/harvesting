class AddCompilerUriToTraits < ActiveRecord::Migration[5.2]
  def change
    add_column :traits, :compiler_uri, :string
  end
end
