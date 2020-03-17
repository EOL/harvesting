class ChangeLiteralsToText < ActiveRecord::Migration[4.2]
  def change
    change_column :meta_traits, :literal, :text, comment: 'Sadly, must be text, as some values are quite large.'
    change_column :meta_assocs, :literal, :text, comment: 'Sadly, must be text, as some values are quite large.'
    change_column :assoc_traits, :literal, :text, comment: 'Sadly, must be text, as some values are quite large.'
  end
end
