class ChangeVernacularsVerbatimToText < ActiveRecord::Migration
  def change
    # Can't index this field; too large:
    remove_index "vernaculars", name: "index_vernaculars_on_resource_id_and_verbatim"
    remove_index "vernaculars", name: "index_vernaculars_on_verbatim"
    change_column :vernaculars, :verbatim, :text, comment: 'Sadly, must be text, as some values are quite large (e.g.: FishBase).'
  end
end
