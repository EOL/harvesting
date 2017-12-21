class Field < ActiveRecord::Base
  belongs_to :format, inverse_of: :fields

  acts_as_list scope: :format

  enum validation: %i[must_be_integers must_be_numerical must_know_uris]

  # NOTE: Yes, this is a long list, but it's a succinct list of all of the types of input that we can parse. The
  # behaviors for each are handled by ResourceHarvester, q.v. NOTE: to_ignored fields, if altered between harvests,
  # STILL trigger a diff, even though nothing will change!
  enum mapping:
    # TODO: This is dumb. Change this to an associated table, and use seeds to "intuit" all of the values possible in
    # that table right from the code.

    # NOTE: things that can have references: taxa, media, measurements, assocs. Each of them can have *multiple* refs,
    # separated by "some safe char," which we will store in the submapping.
    %i[ to_ignored

        to_nodes_pk to_nodes_scientific to_nodes_parent_fk to_nodes_ancestor to_nodes_rank
        to_nodes_further_information_url to_taxonomic_status to_nodes_accepted_name_fk to_nodes_remarks
        to_nodes_publication to_nodes_page_id to_nodes_identifiers to_nodes_ref_fks to_nodes_landmark
        to_nodes_dataset_id

        to_vernaculars_verbatim to_vernaculars_source to_vernaculars_language to_vernaculars_locality
        to_vernaculars_preferred to_vernacular_nodes_fk to_vernaculars_remarks

        to_refs_pk to_refs_body to_refs_part to_refs_url to_refs_doi

        to_attributions_pk to_attributions_name to_attributions_role to_attributions_email to_attributions_url

        to_media_pk to_media_nodes_fk to_section to_media_type to_media_subtype to_media_license to_media_language
        to_format to_derived_from to_bibliographic_citation to_attributions_fk to_media_name to_media_description
        to_media_source_url to_media_source_page_url to_media_rights_statement to_media_usage_statement to_media_owner
        to_media_lat to_media_long to_media_lat_literal to_media_long_literal to_media_locality to_media_ref_fks

        to_occurrences_pk to_occurrences_nodes_fk to_occurrences_sex to_occurrences_lifestage to_occurrences_lat
        to_occurrences_long to_occurrences_lat_literal to_occurrences_long_literal to_occurrences_locality
        to_occurrences_meta

        to_traits_pk to_traits_occurrence_fk to_traits_measurement_of_taxon to_traits_parent_pk to_traits_assoc_node_fk
        to_traits_predicate to_traits_value to_traits_units to_traits_statistical_method to_traits_source
        to_traits_ref_fks to_traits_meta

        to_associations_pk to_associations_occurrence_fk to_associations_target_occurrence_fk to_associations_predicate
        to_associations_source to_associations_ref_fks to_associations_meta

      ]
      # SORRY! It has become unreasonable to attempt to keep these in order, so everything after the "to_associations*"
      # block is just in the order they were added. :| If we ever do a "full reset," it will be worth reorganizing
      # these.

  enum special_handling: %i[iso_639_1 iso_639_3]
end
