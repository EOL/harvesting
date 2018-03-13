class MergeAgentsAndAttributions < ActiveRecord::Migration
  def change
    drop_table :agents
    add_column :attributions, :other_info, :text,
               comment: 'Any information stored by the resource that we didn\'t have a column for.'
    # Keep it simple: we'll just use I18n to handle roles.
    drop_table :roles
    remove_column :attributions, :role_id
    add_column :attributions, :role
    rename_table :attributions_contents, :content_attributions

  end
end
