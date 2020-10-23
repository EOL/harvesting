class AddUriFieldsToOccurrence < ActiveRecord::Migration[5.2]
  def change
    add_column :occurrences, :sex_term_uri, :string
    add_column :occurrences, :lifestage_term_uri, :string

    Occurrence.propagate_id(fk: 'sex_term_id', other: 'terms.id', set: 'sex_term_uri', with: 'uri')
    Occurrence.propagate_id(fk: 'lifestage_term_id', other: 'terms.id', set: 'lifestage_term_uri', with: 'uri')
  end
end
