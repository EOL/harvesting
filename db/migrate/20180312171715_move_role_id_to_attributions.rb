class MoveRoleIdToAttributions < ActiveRecord::Migration
  def change
    # NOTE: Not bothering with moving the data in this migration; it was never used.
    add_column :attributions, :role_id, :integer,
               comment: 'note that this allows nulls... this should be exceedinly rare, but probably worth allowing.'
    remove_column :attributions_contents, :role_id
    add_column :roles, :position, :integer, comment: 'Lowest values are shown first (and considered fist for owners)'
  end
end
