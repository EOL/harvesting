class SpeedUpResourcesPage < ActiveRecord::Migration
  def change
    add_column :harvests, :nodes_count, :integer
    add_column :harvests, :identifiers_count, :integer
    add_column :harvests, :scientific_names_count, :integer
    add_column :resources, :root_nodes_count, :integer
    Harvest.find_each do |harvest|
      harvest.update_attributes(nodes_count: harvest.nodes.count,
                                identifiers_count: harvest.identifiers.count,
                                scientific_names_count: ScientificName.where(harvest_id: harvest.id).count)
    end
    Resource.find_each do |resource|
      resource.update_attribute(:root_nodes_count, resource.nodes.root.published.count)
    end
  end
end
