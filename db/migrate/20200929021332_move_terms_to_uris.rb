class MoveTermsToUris < ActiveRecord::Migration[5.2]
  def change
    term_uris = {}
    EolTerms.list.each do |term|
      term_uris[term['uri']] = nil
    end
    bad_uris = {}
    Term.find_each do |term|
      # raise "Missing EolTerm for #{term.uri}" unless term_uris.key?(term.uri)
      bad_uris[term.uri] = term.id
      next unless term_uris.key?(term.uri)

      term_uris[term.uri] = term.id
    end

    begin
      add_column :assoc_traits, :predicate_term_uri, :string
      add_column :assoc_traits, :object_term_uri, :string
      add_column :assoc_traits, :units_term_uri, :string
      add_column :assoc_traits, :statistical_method_term_uri, :string

      add_column :assocs, :predicate_term_uri, :string
      add_column :assocs, :sex_term_uri, :string
      add_column :assocs, :lifestage_term_uri, :string

      add_column :occurrence_metadata, :predicate_term_uri, :string
      add_column :occurrence_metadata, :object_term_uri, :string
      add_column :occurrence_metadata, :units_term_uri, :string
      add_column :occurrence_metadata, :statistical_method_term_uri, :string

      add_column :traits, :predicate_term_uri, :string
      add_column :traits, :object_term_uri, :string
      add_column :traits, :units_term_uri, :string
      add_column :traits, :statistical_method_term_uri, :string
      add_column :traits, :sex_term_uri, :string
      add_column :traits, :lifestage_term_uri, :string

      puts "#{term_uris.size} URIs to update..."
      print "AssocTrait."
      AssocTrait.propagate_id(fk: 'predicate_term_id', other: 'terms.id', set: 'predicate_term_uri', with: 'uri')
      print '.'
      AssocTrait.propagate_id(fk: 'object_term_id', other: 'terms.id', set: 'object_term_uri', with: 'uri')
      print '.'
      AssocTrait.propagate_id(fk: 'units_term_id', other: 'terms.id', set: 'units_term_uri', with: 'uri')
      print '.'
      AssocTrait.propagate_id(fk: 'statistical_method_term_id', other: 'terms.id', set: 'statistical_method_term_uri', with: 'uri')
      print 'Assoc.'
      Assoc.propagate_id(fk: 'predicate_term_id', other: 'terms.id', set: 'predicate_term_uri', with: 'uri')
      print '.'
      Assoc.propagate_id(fk: 'sex_term_id', other: 'terms.id', set: 'sex_term_uri', with: 'uri')
      print '.'
      Assoc.propagate_id(fk: 'lifestage_term_id', other: 'terms.id', set: 'lifestage_term_uri', with: 'uri')
      print 'OccMeta.'
      OccurrenceMetadatum.propagate_id(fk: 'predicate_term_id', other: 'terms.id', set: 'predicate_term_uri', with: 'uri')
      print '.'
      OccurrenceMetadatum.propagate_id(fk: 'object_term_id', other: 'terms.id', set: 'object_term_uri', with: 'uri')
      print '.'
      OccurrenceMetadatum.propagate_id(fk: 'units_term_id', other: 'terms.id', set: 'units_term_uri', with: 'uri')
      print '.'
      OccurrenceMetadatum.propagate_id(fk: 'statistical_method_term_id', other: 'terms.id', set: 'statistical_method_term_uri', with: 'uri')
      print 'Trait.'
      Trait.propagate_id(fk: 'predicate_term_id', other: 'terms.id', set: 'predicate_term_uri', with: 'uri')
      print '.'
      Trait.propagate_id(fk: 'object_term_id', other: 'terms.id', set: 'object_term_uri', with: 'uri')
      print '.'
      Trait.propagate_id(fk: 'units_term_id', other: 'terms.id', set: 'units_term_uri', with: 'uri')
      print '.'
      Trait.propagate_id(fk: 'statistical_method_term_id', other: 'terms.id', set: 'statistical_method_term_uri', with: 'uri')
      print '.'
      Trait.propagate_id(fk: 'sex_term_id', other: 'terms.id', set: 'sex_term_uri', with: 'uri')
      print '.'
      Trait.propagate_id(fk: 'lifestage_term_id', other: 'terms.id', set: 'lifestage_term_uri', with: 'uri')
      puts "\n"

      # Aaaaaactually, I think I'll delete the _ids in a second migration after I'm happy with these.

    ensure
      unless bad_uris.empty?
        puts "THERE WERE #{bad_uris.size} Terms WHICH ARE NOT RECOGNIZED:"
        puts 'It is NOT okay to publish resources that use these terms, you will have to manually handle them.'
        bad_uris.each do |uri, id|
          puts "#{uri} { Term.find(#{id}) }"
        end
      end
    end
  end
end
