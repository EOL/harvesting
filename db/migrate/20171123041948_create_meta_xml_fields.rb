class CreateMetaXmlFields < ActiveRecord::Migration
  def change
    create_table :meta_xml_fields do |t|
      t.string :term
      t.string :for_format
      t.string :represents
      t.string :submapping
      t.boolean :is_unique
      t.boolean :is_required
    end
  end
end
