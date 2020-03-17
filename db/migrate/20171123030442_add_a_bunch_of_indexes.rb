class AddABunchOfIndexes < ActiveRecord::Migration[4.2]
  def change
    remove_index 'articles', name: 'index_articles_on_resource_id_and_resource_pk'
    add_index 'articles', ['harvest_id', 'resource_pk'], name: 'index_articles_on_harvest_id_and_resource_pk', using: :btree
    add_index 'articles_references', ['harvest_id', 'ref_resource_fk'],
              name: 'index_articles_references_on_harvest_id_and_ref_resource_fk', using: :btree
    add_index 'articles_references', ['harvest_id', 'article_resource_fk'],
              name: 'index_articles_references_on_harvest_id_and_article_resource_fk', using: :btree
    add_index 'assoc_traits', ['harvest_id', 'trait_resource_pk'],
              name: 'index_assoc_traits_on_harvest_id_and_trait_resource_pk', using: :btree
    add_index 'assocs', ['resource_pk'], name: 'index_assocs_on_resource_pk', using: :btree
    add_index 'assocs_references', ['harvest_id', 'ref_resource_fk'],
              name: 'index_assocs_references_on_harvest_id_and_ref_resource_fk', using: :btree
    add_index 'assocs_references', ['harvest_id', 'assoc_resource_fk'],
              name: 'index_assocs_references_on_harvest_id_and_assoc_resource_fk', using: :btree
    remove_index 'attributions', name: 'index_attributions_on_resource_id_and_resource_pk'
    add_index 'attributions', ['harvest_id', 'resource_pk'],
              name: 'index_attributions_on_harvest_id_and_resource_pk', using: :btree
    remove_index 'links', name: 'index_links_on_resource_id_and_resource_pk'
    add_index 'links', ['harvest_id', 'resource_pk'], name: 'index_links_on_harvest_id_and_resource_pk', using: :btree
    remove_index 'media', name: 'index_media_on_resource_id_and_resource_pk'
    add_index 'media', ['harvest_id', 'resource_pk'], name: 'index_media_on_harvest_id_and_resource_pk', using: :btree
    add_index 'media', ['harvest_id', 'node_resource_pk'],
              name: 'index_media_on_harvest_id_and_node_resource_pk', using: :btree
    add_index 'media', ['harvest_id', 'bibliographic_citation_fk'],
              name: 'index_media_on_harvest_id_and_bibliographic_citation_fk', using: :btree
    add_index 'media_references', ['harvest_id', 'ref_resource_fk'],
              name: 'index_media_references_on_harvest_id_and_ref_resource_fk', using: :btree
    add_index 'media_references', ['harvest_id', 'medium_resource_fk'],
              name: 'index_media_references_on_harvest_id_and_medium_resource_fk', using: :btree
    add_index 'meta_assocs', ['harvest_id', 'assoc_resource_fk'],
              name: 'index_meta_assocs_on_harvest_id_and_assoc_resource_fk', using: :btree
    add_index 'meta_traits', ['harvest_id', 'trait_resource_pk'],
              name: 'index_meta_traits_on_harvest_id_and_trait_resource_pk', using: :btree
    add_index 'node_ancestors', ['resource_id', 'ancestor_fk'],
              name: 'index_node_ancestors_on_resource_id_and_ancestor_fk', using: :btree
    add_index 'nodes', ['parent_resource_pk'], name: 'index_nodes_on_parent_resource_pk', using: :btree
    add_index 'nodes_references', ['harvest_id', 'ref_resource_fk'],
              name: 'index_nodes_references_on_harvest_id_and_ref_resource_fk', using: :btree
    add_index 'nodes_references', ['harvest_id', 'node_resource_fk'],
              name: 'index_nodes_references_on_harvest_id_and_node_resource_fk', using: :btree
    add_index 'occurrence_metadata', ['harvest_id', 'resource_pk'],
              name: 'index_occurrence_metadata_on_harvest_id_and_resource_pk', using: :btree
    add_index 'occurrence_metadata', ['harvest_id', 'occurrence_resource_pk'],
              name: 'index_occurrence_metadata_on_harvest_id_and_occurrence_resourc', using: :btree
    add_index 'occurrences', ['harvest_id', 'node_resource_pk'],
              name: 'index_occurrences_on_harvest_id_and_node_resource_pk', using: :btree
    remove_index 'references', name: 'index_references_on_resource_id_and_resource_pk'
    add_index 'references', ['harvest_id', 'resource_pk'],
              name: 'index_references_on_harvest_id_and_resource_pk', using: :btree
    add_index 'scientific_names_references', ['harvest_id', 'ref_resource_fk'],
              name: 'index_s_names_refs_on_harv_and_ref_resource_fk', using: :btree
    add_index 'scientific_names_references', ['harvest_id', 'name_resource_fk'],
              name: 'index_s_names_refs_on_harv_and_name_resource_fk', using: :btree
    remove_index 'traits', name: 'index_traits_on_resource_id_and_resource_pk'
    add_index 'traits', ['harvest_id', 'resource_pk'], name: 'index_traits_on_harvest_id_and_resource_pk', using: :btree
    add_index 'traits_references', ['harvest_id', 'ref_resource_fk'],
              name: 'index_traits_references_on_harvest_id_and_ref_resource_fk', using: :btree
    add_index 'traits_references', ['harvest_id', 'trait_resource_fk'],
              name: 'index_traits_references_on_harvest_id_and_trait_resource_fk', using: :btree
    add_index 'vernaculars', ['harvest_id', 'node_resource_pk'],
              name: 'index_vernaculars_on_harvest_id_and_node_resource_pk', using: :btree
  end
end
