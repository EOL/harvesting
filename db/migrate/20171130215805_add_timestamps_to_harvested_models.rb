class AddTimestampsToHarvestedModels < ActiveRecord::Migration[4.2]
  def change
    # NOTE: these should really have null: false, but ... can't migrate that. :S  TODO
    add_column :scientific_names, :created_at, :datetime
    add_column :scientific_names, :updated_at, :datetime
    add_column :vernaculars, :created_at, :datetime
    add_column :vernaculars, :updated_at, :datetime
    # ScientificName.update_all(created_at: 4.days.ago, updated_at: 3.days.ago)
    # Vernacular.update_all(created_at: 4.days.ago, updated_at: 3.days.ago)
  end
end
