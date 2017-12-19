class AddOccurrenceIdToDataTables < ActiveRecord::Migration
  def change
    add_column :traits, :occurrence_id, :integer
    add_column :assocs, :occurrence_id, :integer
    add_column :assocs, :target_occurrence_id, :integer
    add_index :traits, :occurrence_id
    add_index :assocs, :occurrence_id
    add_index :assocs, :target_occurrence_id
    Harvest.pluck(:id).each do |harvest_id|
      Trait.propagate_id(harvest_id: harvest_id, fk: 'occurrence_resource_pk', other: 'occurrences.resource_pk',
                         set: 'occurrence_id', with: 'id')
      Assoc.propagate_id(harvest_id: harvest_id, fk: 'occurrence_resource_pk', other: 'occurrences.resource_pk',
                         set: 'occurrence_id', with: 'id')
    end
  end
end
