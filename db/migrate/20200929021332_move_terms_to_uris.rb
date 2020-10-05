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
      # add_column :assoc_traits, :predicate_term_uri, :string
      # add_column :assoc_traits, :object_term_uri, :string
      # add_column :assoc_traits, :units_term_uri, :string
      # add_column :assoc_traits, :statistical_method_term_uri, :string
      #
      # add_column :assocs, :predicate_term_uri, :string
      # add_column :assocs, :sex_term_uri, :string
      # add_column :assocs, :lifestage_term_uri, :string
      #
      # add_column :occurrence_metadata, :predicate_term_uri, :string
      # add_column :occurrence_metadata, :object_term_uri, :string
      # add_column :occurrence_metadata, :units_term_uri, :string
      # add_column :occurrence_metadata, :statistical_method_term_uri, :string
      #
      # add_column :traits, :predicate_term_uri, :string
      # add_column :traits, :object_term_uri, :string
      # add_column :traits, :units_term_uri, :string
      # add_column :traits, :statistical_method_term_uri, :string
      # add_column :traits, :sex_term_uri, :string
      # add_column :traits, :lifestage_term_uri, :string

      puts "#{term_uris.size} URIs to update..."
      term_uris.each do |uri, id|
        print "#{id}: AssocTrait."
        AssocTrait.where(predicate_term_id: id).update_all(predicate_term_uri: uri)
        print '.'
        AssocTrait.where(object_term_id: id).update_all(object_term_uri: uri)
        print '.'
        AssocTrait.where(units_term_id: id).update_all(units_term_uri: uri)
        print '.'
        AssocTrait.where(statistical_method_term_id: id).update_all(statistical_method_term_uri: uri)
        print 'Assoc.'
        Assoc.where(predicate_term_id: id).update_all(predicate_term_uri: uri)
        print '.'
        Assoc.where(sex_term_id: id).update_all(sex_term_uri: uri)
        print '.'
        Assoc.where(lifestage_term_id: id).update_all(lifestage_term_uri: uri)
        print 'OccMeta.'
        OccurrenceMetadatum.where(predicate_term_id: id).update_all(predicate_term_uri: uri)
        print '.'
        OccurrenceMetadatum.where(object_term_id: id).update_all(object_term_uri: uri)
        print '.'
        OccurrenceMetadatum.where(units_term_id: id).update_all(units_term_uri: uri)
        print '.'
        OccurrenceMetadatum.where(statistical_method_term_id: id).update_all(statistical_method_term_uri: uri)
        print 'Trait.'
        Trait.where(predicate_term_id: id).update_all(predicate_term_uri: uri)
        print '.'
        Trait.where(object_term_id: id).update_all(object_term_uri: uri)
        print '.'
        Trait.where(units_term_id: id).update_all(units_term_uri: uri)
        print '.'
        Trait.where(statistical_method_term_id: id).update_all(statistical_method_term_uri: uri)
        print '.'
        Trait.where(sex_term_id: id).update_all(sex_term_uri: uri)
        print '.'
        Trait.where(lifestage_term_id: id).update_all(lifestage_term_uri: uri)
        puts "\n"
      end

      # Aaaaaactually, I think I'll delete the _ids in a second migration after I'm happy with these.

    ensure
      unless bad_uris.empty?
        puts 'THERE WERE Terms WHICH ARE NOT RECOGNIZED:'
        puts 'It is NOT okay to publish resources that use these terms, you will have to manually handle them.'
        bad_uris.each do |uri, id|
          puts "#{uri} { Term.find(#{id}) }"
        end
      end
    end
  end
end
