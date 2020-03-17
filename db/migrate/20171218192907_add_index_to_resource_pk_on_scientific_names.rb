class AddIndexToResourcePkOnScientificNames < ActiveRecord::Migration[4.2]
  def change
    # This is a resonable default, for things that HAD been harvested... it will screw up synonyms, but there's no way
    # to fix without reharvesting them:
    ScientificName.where('resource_pk IS NULL').update_all('resource_pk = node_resource_pk')
    add_index :scientific_names, :resource_pk
  end
end
