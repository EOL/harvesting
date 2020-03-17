class AddDefaultToMetaXml < ActiveRecord::Migration[4.2]
  def change
    add_column :meta_xml_fields, :default_when_blank, :string
  end
end
