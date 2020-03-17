# 20180410180330
class AddDefaultWhenBlankToField < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :default_when_blank, :string,
      comment: 'If the value of the field read from the resource file is empty, use this value instead.'
    Field.where(mapping: Field.mappings[:to_traits_measurement_of_taxon]).update_all(default_when_blank: 'false')
  end
end
