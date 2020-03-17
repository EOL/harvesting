class AddNormalizedUnitsUris < ActiveRecord::Migration[4.2]
  def change
    # NOTE: we only need this on the traits table, as ONLY traits' measurements are searchable. NOT metadata.
    add_column :traits, :normal_units_uri, :string, comment: 'NOTE: this is a URI, *NOT* an ID to the terms table!'
    add_column :traits, :normal_measurement, :string
  end
end
