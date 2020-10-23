class AddUriFieldsToMetaAssoc < ActiveRecord::Migration[5.2]
  def change
    add_column :meta_assocs, :predicate_term_uri, :string
    add_column :meta_assocs, :object_term_uri, :string
    add_column :meta_assocs, :units_term_uri, :string
    add_column :meta_assocs, :statistical_method_term_uri, :string

    MetaAssoc.propagate_id(fk: 'predicate_term_id', other: 'terms.id', set: 'predicate_term_uri', with: 'uri')
    MetaAssoc.propagate_id(fk: 'object_term_id', other: 'terms.id', set: 'object_term_uri', with: 'uri')
    MetaAssoc.propagate_id(fk: 'units_term_id', other: 'terms.id', set: 'units_term_uri', with: 'uri')
    MetaAssoc.propagate_id(fk: 'statistical_method_term_id', other: 'terms.id', set: 'statistical_method_term_uri', with: 'uri')
  end
end
