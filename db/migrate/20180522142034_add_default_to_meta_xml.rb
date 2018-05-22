class AddDefaultToMetaXml < ActiveRecord::Migration
  def change
    add_column :meta_xml_fields, :default_when_blank, :string
  end
end
