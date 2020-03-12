# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_12_174303) do

  create_table "articles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "guid", null: false
    t.string "resource_pk", null: false
    t.string "language_code_verbatim"
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "license_id", null: false
    t.integer "language_id"
    t.integer "location_id"
    t.integer "stylesheet_id"
    t.integer "javascript_id"
    t.integer "bibliographic_citation_id"
    t.text "owner"
    t.string "name"
    t.string "source_url", limit: 2083
    t.text "body", limit: 16777215
    t.integer "removed_by_harvest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "node_id"
    t.string "node_resource_pk"
    t.index ["guid"], name: "index_articles_on_guid", length: 191
    t.index ["harvest_id"], name: "index_articles_on_harvest_id"
    t.index ["node_resource_pk"], name: "node_resource_pk", length: 191
    t.index ["resource_id"], name: "index_articles_on_resource_id"
    t.index ["resource_pk"], name: "resource_pk", length: 191
  end

  create_table "articles_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id"
    t.integer "article_id"
    t.integer "reference_id"
    t.string "ref_resource_fk", null: false
    t.string "article_resource_fk", null: false
    t.index ["article_id"], name: "index_articles_references_on_article_id"
    t.index ["harvest_id", "article_resource_fk"], name: "index_articles_references_on_harvest_id_and_article_resource_fk"
    t.index ["harvest_id", "ref_resource_fk"], name: "index_articles_references_on_harvest_id_and_ref_resource_fk"
    t.index ["harvest_id"], name: "index_articles_references_on_harvest_id"
    t.index ["reference_id"], name: "index_articles_references_on_reference_id"
  end

  create_table "articles_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "article_id"
    t.integer "section_id", null: false
    t.string "article_pk", null: false
    t.integer "harvest_id", null: false
  end

  create_table "assoc_traits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "trait_id"
    t.integer "predicate_term_id", null: false
    t.integer "object_term_id"
    t.integer "units_term_id"
    t.integer "statistical_method_term_id"
    t.integer "removed_by_harvest_id"
    t.string "trait_resource_pk", null: false
    t.string "measurement"
    t.text "literal"
    t.text "source"
    t.index ["harvest_id", "trait_resource_pk"], name: "index_assoc_traits_on_harvest_id_and_trait_resource_pk"
    t.index ["harvest_id"], name: "index_assoc_traits_on_harvest_id"
    t.index ["resource_id"], name: "index_assoc_traits_on_resource_id"
  end

  create_table "assocs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "removed_by_harvest_id"
    t.integer "predicate_term_id", null: false
    t.integer "node_id"
    t.integer "target_node_id"
    t.integer "sex_term_id"
    t.integer "lifestage_term_id"
    t.string "resource_pk", null: false
    t.string "occurrence_resource_fk"
    t.string "target_occurrence_resource_fk"
    t.text "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "occurrence_id"
    t.integer "target_occurrence_id"
    t.index ["harvest_id"], name: "index_assocs_on_harvest_id"
    t.index ["node_id"], name: "index_assocs_on_node_id"
    t.index ["occurrence_id"], name: "index_assocs_on_occurrence_id"
    t.index ["occurrence_resource_fk"], name: "index_assocs_on_occurrence_resource_fk"
    t.index ["resource_id"], name: "index_assocs_on_resource_id"
    t.index ["resource_pk"], name: "index_assocs_on_resource_pk"
    t.index ["target_node_id"], name: "index_assocs_on_target_node_id"
    t.index ["target_occurrence_id"], name: "index_assocs_on_target_occurrence_id"
    t.index ["target_occurrence_resource_fk"], name: "index_assocs_on_target_occurrence_resource_fk"
  end

  create_table "assocs_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id"
    t.integer "assoc_id"
    t.integer "reference_id"
    t.string "ref_resource_fk", null: false
    t.string "assoc_resource_fk", null: false
    t.index ["assoc_id"], name: "index_assocs_references_on_assoc_id"
    t.index ["harvest_id", "assoc_resource_fk"], name: "index_assocs_references_on_harvest_id_and_assoc_resource_fk"
    t.index ["harvest_id", "ref_resource_fk"], name: "index_assocs_references_on_harvest_id_and_ref_resource_fk"
    t.index ["harvest_id"], name: "index_assocs_references_on_harvest_id"
    t.index ["reference_id"], name: "index_assocs_references_on_reference_id"
  end

  create_table "attributions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.string "resource_pk", null: false
    t.text "name"
    t.string "email"
    t.integer "removed_by_harvest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "other_info"
    t.string "role"
    t.string "url", limit: 2083
    t.index ["harvest_id", "resource_pk"], name: "index_attributions_on_harvest_id_and_resource_pk"
    t.index ["harvest_id"], name: "index_attributions_on_harvest_id"
  end

  create_table "bibliographic_citations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_pk", null: false
    t.integer "harvest_id", null: false
    t.integer "resource_id", null: false
  end

  create_table "content_attributions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "attribution_id"
    t.integer "content_id"
    t.string "content_type", null: false
    t.string "content_resource_fk", null: false
    t.string "attribution_resource_fk", null: false
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.index ["attribution_id"], name: "index_content_attributions_on_attribution_id"
    t.index ["attribution_resource_fk", "harvest_id"], name: "by_harvest_attribution_resource_fk"
    t.index ["content_type", "content_id"], name: "index_content_attributions_on_content_type_and_content_id"
    t.index ["content_type", "content_resource_fk", "harvest_id"], name: "by_harvest_content_resource_fk"
    t.index ["harvest_id"], name: "index_content_attributions_on_harvest_id"
  end

  create_table "crono_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log", limit: 4294967295
    t.datetime "last_performed_at"
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "data_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "reference_id", null: false
    t.integer "data_id", null: false
    t.string "data_type", null: false
    t.index ["data_type", "data_id"], name: "index_data_references_on_data_type_and_data_id"
  end

  create_table "datasets", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "id", null: false
    t.text "name", null: false
    t.text "link", null: false
    t.string "publisher"
    t.string "supplier"
    t.text "metadata"
    t.index ["id"], name: "index_datasets_on_id"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    t.index ["queue"], name: "index_delayed_jobs_on_queue"
  end

  create_table "fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "format_id", null: false
    t.integer "position", null: false
    t.integer "validation"
    t.integer "mapping"
    t.integer "special_handling"
    t.string "submapping"
    t.string "expected_header"
    t.boolean "unique_in_format", default: false, null: false
    t.boolean "can_be_empty", default: true, null: false
    t.string "default_when_blank"
  end

  create_table "formats", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id"
    t.integer "sheet", default: 1, null: false
    t.integer "header_lines", default: 1, null: false
    t.integer "data_begins_on_line", default: 1, null: false
    t.integer "file_type", default: 0
    t.integer "represents", null: false
    t.string "get_from", null: false
    t.string "file"
    t.string "diff"
    t.string "field_sep", limit: 4, default: ","
    t.string "line_sep", limit: 4, default: "\n"
    t.boolean "utf8", default: false, null: false
    t.integer "line_count"
    t.index ["harvest_id"], name: "index_formats_on_harvest_id"
  end

  create_table "harvest_processes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id"
    t.text "method_breadcrumbs"
    t.integer "current_group"
    t.integer "current_group_size"
    t.text "current_group_times"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "harvests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "time_in_minutes"
    t.boolean "hold", default: false, null: false
    t.datetime "fetched_at"
    t.datetime "validated_at"
    t.datetime "deltas_created_at"
    t.datetime "stored_at"
    t.datetime "consistency_checked_at"
    t.datetime "names_parsed_at"
    t.datetime "nodes_matched_at"
    t.datetime "ancestry_built_at"
    t.datetime "units_normalized_at"
    t.datetime "linked_at"
    t.datetime "indexed_at"
    t.datetime "failed_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stage"
    t.integer "nodes_count"
    t.integer "identifiers_count"
    t.integer "scientific_names_count"
  end

  create_table "hlogs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id", null: false
    t.integer "format_id"
    t.integer "category"
    t.text "message"
    t.text "backtrace"
    t.integer "line"
    t.datetime "created_at"
    t.index ["harvest_id"], name: "index_hlogs_on_harvest_id"
  end

  create_table "identifiers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "node_id"
    t.string "identifier"
    t.string "node_resource_pk"
    t.index ["harvest_id"], name: "index_identifiers_on_harvest_id"
    t.index ["identifier"], name: "index_identifiers_on_identifier"
    t.index ["node_id"], name: "index_identifiers_on_node_id"
    t.index ["node_resource_pk"], name: "index_identifiers_on_node_resource_pk"
  end

  create_table "languages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "code"
    t.string "group_code"
  end

  create_table "licenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "source_url", limit: 2083
    t.string "icon_url", limit: 2083
    t.boolean "can_be_chosen_by_partners", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "guid", null: false
    t.string "resource_pk", null: false
    t.string "language_code_verbatim"
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "language_id"
    t.string "name"
    t.string "source_url", limit: 2083
    t.text "description", null: false
    t.integer "removed_by_harvest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guid"], name: "index_links_on_guid"
    t.index ["harvest_id", "resource_pk"], name: "index_links_on_harvest_id_and_resource_pk"
    t.index ["harvest_id"], name: "index_links_on_harvest_id"
    t.index ["resource_id"], name: "index_links_on_resource_id"
  end

  create_table "links_sections", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "link_id", null: false
    t.integer "section_id", null: false
  end

  create_table "locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "lat_literal"
    t.string "long_literal"
    t.string "alt_literal"
    t.string "locality"
    t.string "created"
    t.decimal "lat", precision: 64, scale: 12
    t.decimal "long", precision: 64, scale: 12
    t.decimal "alt", precision: 64, scale: 12
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "guid", null: false
    t.string "resource_pk", null: false
    t.string "node_resource_pk", null: false
    t.string "unmodified_url", limit: 2083
    t.string "name_verbatim"
    t.string "name"
    t.string "source_page_url", limit: 2083
    t.string "source_url", limit: 2083
    t.string "base_url", limit: 2083
    t.string "rights_statement"
    t.string "usage_statement"
    t.string "sizes"
    t.string "bibliographic_citation_fk"
    t.string "language_code_verbatim"
    t.integer "subclass", default: 0, null: false
    t.integer "format", default: 0, null: false
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "node_id"
    t.integer "license_id"
    t.integer "language_id"
    t.integer "location_id"
    t.integer "w"
    t.integer "h"
    t.integer "crop_x_pct"
    t.integer "crop_y_pct"
    t.integer "crop_w_pct"
    t.integer "crop_h_pct"
    t.integer "bibliographic_citation_id"
    t.text "owner"
    t.text "description_verbatim"
    t.text "description"
    t.text "derived_from"
    t.integer "removed_by_harvest_id"
    t.datetime "downloaded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guid"], name: "index_media_on_guid"
    t.index ["harvest_id", "bibliographic_citation_fk"], name: "index_media_on_harvest_id_and_bibliographic_citation_fk"
    t.index ["harvest_id", "node_resource_pk"], name: "index_media_on_harvest_id_and_node_resource_pk"
    t.index ["harvest_id", "resource_pk"], name: "index_media_on_harvest_id_and_resource_pk"
    t.index ["harvest_id"], name: "index_media_on_harvest_id"
    t.index ["node_id"], name: "index_media_on_node_id"
    t.index ["resource_id"], name: "index_media_on_resource_id"
    t.index ["subclass"], name: "index_media_on_subclass"
  end

  create_table "media_download_error", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "content_id", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_media_download_error_on_content_id"
  end

  create_table "media_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id"
    t.integer "medium_id"
    t.integer "reference_id"
    t.string "ref_resource_fk", null: false
    t.string "medium_resource_fk", null: false
    t.index ["harvest_id", "medium_resource_fk"], name: "index_media_references_on_harvest_id_and_medium_resource_fk"
    t.index ["harvest_id", "ref_resource_fk"], name: "index_media_references_on_harvest_id_and_ref_resource_fk"
    t.index ["harvest_id"], name: "index_media_references_on_harvest_id"
    t.index ["medium_id"], name: "index_media_references_on_medium_id"
    t.index ["reference_id"], name: "index_media_references_on_reference_id"
  end

  create_table "media_sections", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "medium_id", null: false
    t.integer "section_id", null: false
  end

  create_table "meta_assocs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "removed_by_harvest_id"
    t.integer "assoc_id"
    t.integer "predicate_term_id", null: false
    t.integer "object_term_id"
    t.integer "units_term_id"
    t.integer "statistical_method_term_id"
    t.string "assoc_resource_fk"
    t.string "measurement"
    t.text "literal"
    t.text "source"
    t.index ["harvest_id", "assoc_resource_fk"], name: "index_meta_assocs_on_harvest_id_and_assoc_resource_fk"
  end

  create_table "meta_traits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "removed_by_harvest_id"
    t.integer "trait_id"
    t.integer "predicate_term_id", null: false
    t.integer "object_term_id"
    t.integer "units_term_id"
    t.integer "statistical_method_term_id"
    t.string "trait_resource_pk", null: false
    t.string "measurement"
    t.text "literal"
    t.text "source"
    t.index ["harvest_id", "trait_resource_pk"], name: "index_meta_traits_on_harvest_id_and_trait_resource_pk"
    t.index ["trait_id"], name: "index_meta_traits_on_trait_id"
  end

  create_table "meta_xml_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "term"
    t.string "for_format"
    t.string "represents"
    t.string "submapping"
    t.boolean "is_unique"
    t.boolean "is_required"
    t.string "default_when_blank"
  end

  create_table "node_ancestors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "node_id", null: false
    t.integer "ancestor_id", null: false
    t.integer "depth"
    t.string "ancestor_fk"
    t.index ["ancestor_id"], name: "index_node_ancestors_on_ancestor_id"
    t.index ["node_id"], name: "index_node_ancestors_on_node_id"
    t.index ["resource_id", "ancestor_fk"], name: "index_node_ancestors_on_resource_id_and_ancestor_fk"
    t.index ["resource_id"], name: "index_node_ancestors_on_resource_id"
  end

  create_table "nodes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "page_id"
    t.integer "parent_id"
    t.integer "scientific_name_id"
    t.integer "removed_by_harvest_id"
    t.integer "landmark", default: 0
    t.string "canonical"
    t.string "taxonomic_status_verbatim"
    t.string "resource_pk"
    t.string "parent_resource_pk"
    t.string "further_information_url", limit: 2083
    t.string "rank"
    t.string "rank_verbatim"
    t.boolean "in_unmapped_area", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "matching_log"
    t.boolean "is_on_page_in_dynamic_hierarchy", default: false
    t.index ["harvest_id"], name: "index_nodes_on_harvest_id"
    t.index ["page_id"], name: "index_nodes_on_page_id"
    t.index ["parent_id"], name: "index_nodes_on_parent_id"
    t.index ["parent_resource_pk"], name: "index_nodes_on_parent_resource_pk"
    t.index ["resource_id"], name: "index_nodes_on_resource_id"
    t.index ["resource_pk"], name: "index_nodes_on_resource_pk"
  end

  create_table "nodes_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id"
    t.integer "node_id"
    t.integer "reference_id"
    t.string "ref_resource_fk", null: false
    t.string "node_resource_fk", null: false
    t.index ["harvest_id", "node_resource_fk"], name: "index_nodes_references_on_harvest_id_and_node_resource_fk"
    t.index ["harvest_id", "ref_resource_fk"], name: "index_nodes_references_on_harvest_id_and_ref_resource_fk"
    t.index ["harvest_id"], name: "index_nodes_references_on_harvest_id"
    t.index ["node_id"], name: "index_nodes_references_on_node_id"
    t.index ["reference_id"], name: "index_nodes_references_on_reference_id"
  end

  create_table "occurrence_metadata", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id"
    t.integer "occurrence_id"
    t.integer "predicate_term_id"
    t.integer "object_term_id"
    t.text "literal"
    t.integer "resource_id"
    t.integer "units_term_id"
    t.integer "statistical_method_term_id"
    t.string "resource_pk"
    t.string "measurement"
    t.string "occurrence_resource_pk"
    t.text "source"
    t.index ["harvest_id", "occurrence_resource_pk"], name: "index_occurrence_metadata_on_harvest_id_and_occurrence_resourc"
    t.index ["harvest_id", "resource_pk"], name: "index_occurrence_metadata_on_harvest_id_and_resource_pk"
    t.index ["harvest_id"], name: "index_occurrence_metadata_on_harvest_id"
  end

  create_table "occurrences", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id"
    t.string "resource_pk", null: false
    t.integer "node_id"
    t.string "node_resource_pk", null: false
    t.string "sex_term_id"
    t.string "lifestage_term_id"
    t.integer "resource_id"
    t.index ["harvest_id", "node_resource_pk"], name: "index_occurrences_on_harvest_id_and_node_resource_pk"
    t.index ["harvest_id"], name: "index_occurrences_on_harvest_id"
    t.index ["resource_pk"], name: "index_occurrences_on_resource_pk"
  end

  create_table "pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "native_node_id", null: false
  end

  create_table "partners", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "abbr", limit: 16
    t.string "short_name", limit: 32, default: "", null: false
    t.string "homepage_url", limit: 2083, default: "", null: false
    t.text "description", null: false
    t.string "links_json", default: "{}", null: false
    t.boolean "auto_publish", default: false, null: false
    t.boolean "not_trusted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partners_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "partner_id", null: false
  end

  create_table "references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.string "resource_pk", null: false
    t.string "url", limit: 2083
    t.string "doi"
    t.integer "removed_by_harvest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["harvest_id", "resource_pk"], name: "index_references_on_harvest_id_and_resource_pk"
    t.index ["harvest_id"], name: "index_references_on_harvest_id"
  end

  create_table "resources", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "position"
    t.integer "min_days_between_harvests", default: 0, null: false
    t.integer "harvest_day_of_month"
    t.integer "nodes_count"
    t.integer "partner_id"
    t.string "harvest_months_json", default: "[]", null: false
    t.string "name", null: false
    t.string "abbr", limit: 16
    t.string "pk_url", limit: 2083, default: "$PK", null: false
    t.boolean "auto_publish", default: false, null: false
    t.boolean "not_trusted", default: false, null: false
    t.boolean "hold_harvesting", default: false, null: false
    t.boolean "might_have_duplicate_taxa", default: false, null: false
    t.boolean "force_harvest", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.text "notes"
    t.boolean "is_browsable", default: false, null: false
    t.integer "default_language_id"
    t.integer "default_license_id"
    t.string "default_rights_statement", limit: 300
    t.text "default_rights_holder"
    t.integer "publish_status"
    t.integer "dataset_license_id"
    t.string "dataset_rights_holder"
    t.string "dataset_rights_statement"
    t.string "opendata_url", limit: 2083
    t.integer "downloaded_media_count", default: 0
    t.integer "failed_downloaded_media_count", default: 0
    t.boolean "classification", default: false
    t.text "skips"
    t.integer "root_nodes_count"
    t.index ["abbr"], name: "index_resources_on_abbr", unique: true
  end

  create_table "scientific_names", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "node_id"
    t.integer "normalized_name_id"
    t.integer "parse_quality"
    t.integer "taxonomic_status"
    t.string "node_resource_pk"
    t.string "taxonomic_status_verbatim"
    t.string "warnings"
    t.string "genus"
    t.string "specific_epithet"
    t.string "infraspecific_epithet"
    t.string "infrageneric_epithet"
    t.string "normalized"
    t.string "canonical"
    t.string "uninomial"
    t.text "verbatim", null: false
    t.text "authorship"
    t.text "publication"
    t.text "remarks"
    t.integer "year"
    t.boolean "is_preferred"
    t.boolean "is_used_for_merges", default: true
    t.boolean "is_publishable", default: true
    t.boolean "hybrid"
    t.boolean "surrogate"
    t.boolean "virus"
    t.integer "removed_by_harvest_id"
    t.string "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "resource_pk"
    t.text "dataset_name"
    t.text "name_according_to"
    t.index ["harvest_id"], name: "index_scientific_names_on_harvest_id"
    t.index ["node_id"], name: "index_scientific_names_on_node_id"
    t.index ["node_resource_pk"], name: "index_scientific_names_on_node_resource_pk"
    t.index ["normalized"], name: "index_scientific_names_on_normalized"
    t.index ["normalized_name_id"], name: "index_scientific_names_on_normalized_name_id"
    t.index ["resource_pk"], name: "index_scientific_names_on_resource_pk"
  end

  create_table "scientific_names_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id"
    t.integer "scientific_name_id"
    t.integer "reference_id"
    t.string "ref_resource_fk", null: false
    t.string "name_resource_fk", null: false
    t.index ["harvest_id", "name_resource_fk"], name: "index_s_names_refs_on_harv_and_name_resource_fk"
    t.index ["harvest_id", "ref_resource_fk"], name: "index_s_names_refs_on_harv_and_ref_resource_fk"
    t.index ["harvest_id"], name: "index_scientific_names_references_on_harvest_id"
    t.index ["reference_id"], name: "index_scientific_names_references_on_reference_id"
    t.index ["scientific_name_id"], name: "index_scientific_names_references_on_scientific_name_id"
  end

  create_table "section", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
  end

  create_table "section_parents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "section_id"
    t.integer "parent_id"
  end

  create_table "section_values", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "section_id"
    t.string "value"
    t.index ["value"], name: "index_section_values_on_value"
  end

  create_table "sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "position"
  end

  create_table "sections_terms", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "section_id", null: false
    t.integer "term_id", null: false
  end

  create_table "terms", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "uri", null: false
    t.string "name"
    t.text "definition"
    t.text "comment"
    t.text "attribution"
    t.boolean "is_hidden_from_overview", default: false
    t.boolean "is_hidden_from_glossary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ontology_information_url", limit: 2083
    t.text "ontology_source_url"
    t.boolean "is_text_only"
    t.boolean "is_verbatim_only"
    t.integer "position"
    t.integer "used_for"
    t.index ["uri"], name: "index_terms_on_uri"
  end

  create_table "traits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "parent_id"
    t.integer "harvest_id", null: false
    t.integer "node_id"
    t.integer "predicate_term_id", null: false
    t.integer "object_term_id"
    t.integer "units_term_id"
    t.integer "statistical_method_term_id"
    t.integer "sex_term_id"
    t.integer "lifestage_term_id"
    t.integer "removed_by_harvest_id"
    t.boolean "of_taxon"
    t.string "occurrence_resource_pk"
    t.string "assoc_resource_pk"
    t.string "parent_pk"
    t.string "resource_pk", null: false
    t.string "measurement"
    t.text "literal"
    t.text "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "occurrence_id"
    t.string "normal_units_uri"
    t.string "normal_measurement"
    t.index ["assoc_resource_pk"], name: "index_traits_on_assoc_resource_pk"
    t.index ["harvest_id", "resource_pk"], name: "index_traits_on_harvest_id_and_resource_pk"
    t.index ["harvest_id"], name: "index_traits_on_harvest_id"
    t.index ["occurrence_id"], name: "index_traits_on_occurrence_id"
    t.index ["occurrence_resource_pk"], name: "index_traits_on_occurrence_resource_pk"
    t.index ["parent_id"], name: "index_traits_on_parent_id"
    t.index ["parent_pk"], name: "index_traits_on_parent_pk"
  end

  create_table "traits_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "harvest_id"
    t.integer "trait_id"
    t.integer "reference_id"
    t.string "ref_resource_fk", null: false
    t.string "trait_resource_fk", null: false
    t.index ["harvest_id", "ref_resource_fk"], name: "index_traits_references_on_harvest_id_and_ref_resource_fk"
    t.index ["harvest_id", "trait_resource_fk"], name: "index_traits_references_on_harvest_id_and_trait_resource_fk"
    t.index ["harvest_id"], name: "index_traits_references_on_harvest_id"
    t.index ["reference_id"], name: "index_traits_references_on_reference_id"
    t.index ["trait_id"], name: "index_traits_references_on_trait_id"
  end

  create_table "unit_conversion", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "from_term_id", null: false
    t.integer "to_term_id", null: false
    t.string "method", null: false
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "is_admin", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "vernaculars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "harvest_id", null: false
    t.integer "node_id"
    t.integer "language_id"
    t.string "node_resource_pk"
    t.text "verbatim"
    t.string "language_code_verbatim"
    t.string "locality"
    t.text "remarks"
    t.text "source"
    t.boolean "is_preferred"
    t.integer "removed_by_harvest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["harvest_id", "node_resource_pk"], name: "index_vernaculars_on_harvest_id_and_node_resource_pk"
    t.index ["harvest_id"], name: "index_vernaculars_on_harvest_id"
  end

end
