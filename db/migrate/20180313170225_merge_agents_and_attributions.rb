class MergeAgentsAndAttributions < ActiveRecord::Migration[4.2]
  def up
    drop_table :agents
    add_column :attributions, :other_info, :text,
               comment: 'Any information stored by the resource that we didn\'t have a column for.'
    # Keep it simple: we'll just use I18n to handle roles.
    drop_table :roles
    remove_column :attributions, :role_id
    add_column :attributions, :role, :string,
               comment: 'value should be lower-case and will be treated as a Rails I18n key.'
    rename_table :attributions_contents, :content_attributions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
