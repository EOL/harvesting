class RemoveRequiredFieldsFromTermIds < ActiveRecord::Migration[5.2]
  def change
    # NOTE: not all of them *were* non-null; I am only fixing the ones I must.
    change_column :assocs, :predicate_term_id, :integer, null: true
    change_column :assoc_traits, :predicate_term_id, :integer, null: true
    change_column :meta_assocs, :predicate_term_id, :integer, null: true
    change_column :meta_traits, :predicate_term_id, :integer, null: true
    change_column :traits, :predicate_term_id, :integer, null: true
  end
end
