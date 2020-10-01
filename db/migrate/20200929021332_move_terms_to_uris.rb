class MoveTermsToUris < ActiveRecord::Migration[5.2]
  def change
    term_uris = {}
    EolTerms.list.each do |term|
      term_uris[term['uri']] = nil
    end
    Term.find_each do |term|
      raise "Missing EolTerm for #{term.uri}" unless term_uris.key?(term.uri)

      term_uris[term.uri] = term.id
    end

    add_column :assoc_traits, :predicate_term_uri, :string
    add_column :assoc_traits, :object_term_uri, :string
    add_column :assoc_traits, :units_term_uri, :string
    add_column :assoc_traits, :statistical_methods_term_uri, :string

    add_column :assocs, :predicate_term_uri, :string
    add_column :assocs, :sex_term_uri, :string
    add_column :assocs, :lifestage_term_uri, :string

    add_column :occurrence_metadata, :predicate_term_uri, :string
    add_column :occurrence_metadata, :object_term_uri, :string
    add_column :occurrence_metadata, :units_term_uri, :string
    add_column :occurrence_metadata, :statistical_methods_term_uri, :string

    add_column :traits, :predicate_term_uri, :string
    add_column :traits, :object_term_uri, :string
    add_column :traits, :units_term_uri, :string
    add_column :traits, :statistical_methods_term_uri, :string
    add_column :traits, :sex_term_uri, :string
    add_column :traits, :lifestage_term_uri, :string

    term_uris.each do |uri, id|
      AssocTrait.where(predicate_term_id: id).update_all(predicate_term_uri: uri)
      AssocTrait.where(object_term_id: id).update_all(object_term_uri: uri)
      AssocTrait.where(units_term_id: id).update_all(units_term_uri: uri)
      AssocTrait.where(statistical_methods_term_id: id).update_all(statistical_methods_term_uri: uri)
      Assoc.where(predicate_term_id: id).update_all(predicate_term_uri: uri)
      Assoc.where(sex_term_id: id).update_all(sex_term_uri: uri)
      Assoc.where(lifestage_term_id: id).update_all(lifestage_term_uri: uri)
      OccurrenceMetadata.where(predicate_term_id: id).update_all(predicate_term_uri: uri)
      OccurrenceMetadata.where(object_term_id: id).update_all(object_term_uri: uri)
      OccurrenceMetadata.where(units_term_id: id).update_all(units_term_uri: uri)
      OccurrenceMetadata.where(statistical_methods_term_id: id).update_all(statistical_methods_term_uri: uri)
      Trait.where(predicate_term_id: id).update_all(predicate_term_uri: uri)
      Trait.where(object_term_id: id).update_all(object_term_uri: uri)
      Trait.where(units_term_id: id).update_all(units_term_uri: uri)
      Trait.where(statistical_methods_term_id: id).update_all(statistical_methods_term_uri: uri)
      Trait.where(sex_term_id: id).update_all(sex_term_uri: uri)
      Trait.where(lifestage_term_id: id).update_all(lifestage_term_uri: uri)
    end

    # Aaaaaactually, I think I'll delete the _ids in a second migration after I'm happy with these.
  end
end
