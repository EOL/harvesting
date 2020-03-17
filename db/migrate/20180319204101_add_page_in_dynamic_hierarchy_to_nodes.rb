class AddPageInDynamicHierarchyToNodes < ActiveRecord::Migration[4.2]
  def change
    add_column :nodes, :is_on_page_in_dynamic_hierarchy, :boolean,
               default: false, comment: 'names_matcher needs to know which page_ids are actually in DH'
    add_index :nodes, :page_id
    if Resoruce.natitve
      Resource.native.nodes.select('id, page_id').find_in_batches(batch_size: 5000) do |batch|
        say_with_time("Updating nodes on pages in the dynamic hierarchy (batch of #{batch.size})") do
          batch.map(&:page_id).each do |pgid|
            Node.where(page_id: pgid).update_all(is_on_page_in_dynamic_hierarchy: true)
          end
        end
      end
    end
  end
end
