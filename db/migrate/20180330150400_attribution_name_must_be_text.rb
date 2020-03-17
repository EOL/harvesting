class AttributionNameMustBeText < ActiveRecord::Migration[4.2]
  def change
    change_column :attributions, :name, :text, comment: "we don't know how long this will be and we cannot control it."
  end
end
