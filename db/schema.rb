# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20171004200142) do

  create_table "agents", force: :cascade do |t|
    t.integer "harvest_id",  limit: 4
    t.string  "resource_pk", limit: 255,   null: false
    t.string  "full_name",   limit: 255
    t.string  "role",        limit: 255
    t.string  "email",       limit: 255
    t.string  "uri",         limit: 255
    t.text    "other_info",  limit: 65535
  end

  create_table "articles", force: :cascade do |t|
    t.string   "guid",                      limit: 255,   null: false
    t.string   "resource_pk",               limit: 255,   null: false
    t.integer  "resource_id",               limit: 4,     null: false
    t.integer  "harvest_id",                limit: 4,     null: false
    t.integer  "license_id",                limit: 4,     null: false
    t.integer  "language_id",               limit: 4
    t.integer  "location_id",               limit: 4
    t.integer  "stylesheet_id",             limit: 4
    t.integer  "javascript_id",             limit: 4
    t.integer  "bibliographic_citation_id", limit: 4
    t.text     "owner",                     limit: 65535, null: false
    t.string   "name",                      limit: 255
    t.string   "source_url",                limit: 255
    t.text     "body",                      limit: 65535, null: false
    t.integer  "removed_by_harvest_id",     limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "articles", ["guid"], name: "index_articles_on_guid", using: :btree
  add_index "articles", ["harvest_id"], name: "index_articles_on_harvest_id", using: :btree
  add_index "articles", ["resource_id", "resource_pk"], name: "index_articles_on_resource_id_and_resource_pk", using: :btree
  add_index "articles", ["resource_id"], name: "index_articles_on_resource_id", using: :btree

  create_table "articles_refs", id: false, force: :cascade do |t|
    t.integer "article_id", limit: 4, null: false
    t.integer "ref_id",     limit: 4, null: false
  end

  add_index "articles_refs", ["article_id"], name: "index_articles_refs_on_article_id", using: :btree

  create_table "articles_sections", id: false, force: :cascade do |t|
    t.integer "article_id", limit: 4, null: false
    t.integer "section_id", limit: 4, null: false
  end

  create_table "associations", force: :cascade do |t|
    t.integer "trait_id", limit: 4, null: false
  end

  create_table "attributions", force: :cascade do |t|
    t.integer  "resource_id",           limit: 4,     null: false
    t.integer  "harvest_id",            limit: 4,     null: false
    t.string   "resource_pk",           limit: 255,   null: false
    t.string   "name",                  limit: 255
    t.string   "email",                 limit: 255
    t.text     "value",                 limit: 65535, null: false
    t.integer  "removed_by_harvest_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "attributions", ["harvest_id"], name: "index_attributions_on_harvest_id", using: :btree
  add_index "attributions", ["resource_id", "resource_pk"], name: "index_attributions_on_resource_id_and_resource_pk", using: :btree

  create_table "attributions_contents", force: :cascade do |t|
    t.integer "attribution_id", limit: 4,   null: false
    t.integer "content_id",     limit: 4,   null: false
    t.string  "content_type",   limit: 255, null: false
    t.integer "role_id",        limit: 4,   null: false
  end

  add_index "attributions_contents", ["attribution_id"], name: "index_attributions_contents_on_attribution_id", using: :btree
  add_index "attributions_contents", ["content_type", "content_id"], name: "index_attributions_contents_on_content_type_and_content_id", using: :btree
  add_index "attributions_contents", ["role_id"], name: "index_attributions_contents_on_role_id", using: :btree

  create_table "bibliographic_citations", force: :cascade do |t|
    t.text     "body",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "data_references", force: :cascade do |t|
    t.integer "reference_id", limit: 4,   null: false
    t.integer "data_id",      limit: 4,   null: false
    t.string  "data_type",    limit: 255, null: false
  end

  add_index "data_references", ["data_type", "data_id"], name: "index_data_references_on_data_type_and_data_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "fields", force: :cascade do |t|
    t.integer "format_id",        limit: 4,                   null: false
    t.integer "position",         limit: 4,                   null: false
    t.integer "validation",       limit: 4
    t.integer "mapping",          limit: 4
    t.integer "special_handling", limit: 4
    t.string  "submapping",       limit: 255
    t.string  "expected_header",  limit: 255
    t.boolean "unique_in_format",             default: false, null: false
    t.boolean "can_be_empty",                 default: true,  null: false
  end

  create_table "formats", force: :cascade do |t|
    t.integer "resource_id",         limit: 4,                   null: false
    t.integer "harvest_id",          limit: 4
    t.integer "sheet",               limit: 4,   default: 1,     null: false
    t.integer "header_lines",        limit: 4,   default: 1,     null: false
    t.integer "data_begins_on_line", limit: 4,   default: 1,     null: false
    t.integer "file_type",           limit: 4,   default: 0
    t.integer "represents",          limit: 4,                   null: false
    t.string  "get_from",            limit: 255,                 null: false
    t.string  "file",                limit: 255
    t.string  "diff",                limit: 255
    t.string  "field_sep",           limit: 4,   default: ","
    t.string  "line_sep",            limit: 4,   default: "\n"
    t.boolean "utf8",                            default: false, null: false
  end

  create_table "harvests", force: :cascade do |t|
    t.integer  "resource_id",            limit: 4,                 null: false
    t.integer  "time_in_minutes",        limit: 4
    t.boolean  "hold",                             default: false, null: false
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
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "hlogs", force: :cascade do |t|
    t.integer  "harvest_id", limit: 4,     null: false
    t.integer  "format_id",  limit: 4
    t.integer  "category",   limit: 4
    t.text     "message",    limit: 65535
    t.text     "backtrace",  limit: 65535
    t.integer  "line",       limit: 4
    t.datetime "created_at"
  end

  create_table "identifiers", force: :cascade do |t|
    t.integer "resource_id",      limit: 4,   null: false
    t.integer "harvest_id",       limit: 4,   null: false
    t.integer "node_id",          limit: 4
    t.string  "identifier",       limit: 255
    t.string  "node_resource_pk", limit: 255
  end

  add_index "identifiers", ["harvest_id"], name: "index_identifiers_on_harvest_id", using: :btree
  add_index "identifiers", ["identifier"], name: "index_identifiers_on_identifier", using: :btree
  add_index "identifiers", ["node_id"], name: "index_identifiers_on_node_id", using: :btree
  add_index "identifiers", ["node_resource_pk"], name: "index_identifiers_on_node_resource_pk", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string "code",       limit: 255
    t.string "group_code", limit: 255
  end

  create_table "licenses", force: :cascade do |t|
    t.string   "name",                      limit: 255,                 null: false
    t.string   "source_url",                limit: 255
    t.string   "icon_url",                  limit: 255
    t.boolean  "can_be_chosen_by_partners",             default: false, null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "links", force: :cascade do |t|
    t.string   "guid",                  limit: 255,   null: false
    t.string   "resource_pk",           limit: 255,   null: false
    t.integer  "resource_id",           limit: 4,     null: false
    t.integer  "harvest_id",            limit: 4,     null: false
    t.integer  "language_id",           limit: 4
    t.string   "name",                  limit: 255
    t.string   "source_url",            limit: 255
    t.text     "description",           limit: 65535, null: false
    t.integer  "removed_by_harvest_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "links", ["guid"], name: "index_links_on_guid", using: :btree
  add_index "links", ["harvest_id"], name: "index_links_on_harvest_id", using: :btree
  add_index "links", ["resource_id", "resource_pk"], name: "index_links_on_resource_id_and_resource_pk", using: :btree
  add_index "links", ["resource_id"], name: "index_links_on_resource_id", using: :btree

  create_table "links_sections", id: false, force: :cascade do |t|
    t.integer "link_id",    limit: 4, null: false
    t.integer "section_id", limit: 4, null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string  "lat_literal",  limit: 255
    t.string  "long_literal", limit: 255
    t.string  "alt_literal",  limit: 255
    t.string  "locality",     limit: 255
    t.string  "created",      limit: 255
    t.decimal "lat",                      precision: 64, scale: 12
    t.decimal "long",                     precision: 64, scale: 12
    t.decimal "alt",                      precision: 64, scale: 12
  end

  create_table "media", force: :cascade do |t|
    t.string   "guid",                      limit: 255,               null: false
    t.string   "resource_pk",               limit: 255,               null: false
    t.string   "node_resource_pk",          limit: 255,               null: false
    t.string   "unmodified_url",            limit: 255
    t.string   "name_verbatim",             limit: 255
    t.string   "name",                      limit: 255
    t.string   "source_page_url",           limit: 255
    t.string   "source_url",                limit: 255
    t.string   "base_url",                  limit: 255
    t.string   "rights_statement",          limit: 255
    t.string   "usage_statement",           limit: 255
    t.string   "sizes",                     limit: 255
    t.integer  "subclass",                  limit: 4,     default: 0, null: false
    t.integer  "format",                    limit: 4,     default: 0, null: false
    t.integer  "resource_id",               limit: 4,                 null: false
    t.integer  "harvest_id",                limit: 4,                 null: false
    t.integer  "node_id",                   limit: 4
    t.integer  "license_id",                limit: 4
    t.integer  "language_id",               limit: 4
    t.integer  "location_id",               limit: 4
    t.integer  "w",                         limit: 4
    t.integer  "h",                         limit: 4
    t.integer  "crop_x_pct",                limit: 4
    t.integer  "crop_y_pct",                limit: 4
    t.integer  "crop_w_pct",                limit: 4
    t.integer  "crop_h_pct",                limit: 4
    t.integer  "bibliographic_citation_id", limit: 4
    t.text     "owner",                     limit: 65535
    t.text     "description_verbatim",      limit: 65535
    t.text     "description",               limit: 65535
    t.integer  "removed_by_harvest_id",     limit: 4
    t.datetime "downloaded_at"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "media", ["guid"], name: "index_media_on_guid", using: :btree
  add_index "media", ["harvest_id"], name: "index_media_on_harvest_id", using: :btree
  add_index "media", ["node_id"], name: "index_media_on_node_id", using: :btree
  add_index "media", ["resource_id", "resource_pk"], name: "index_media_on_resource_id_and_resource_pk", using: :btree
  add_index "media", ["resource_id"], name: "index_media_on_resource_id", using: :btree
  add_index "media", ["subclass"], name: "index_media_on_subclass", using: :btree

  create_table "media_download_error", force: :cascade do |t|
    t.integer  "content_id", limit: 4,     null: false
    t.text     "message",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "media_download_error", ["content_id"], name: "index_media_download_error_on_content_id", using: :btree

  create_table "media_sections", id: false, force: :cascade do |t|
    t.integer "medium_id",  limit: 4, null: false
    t.integer "section_id", limit: 4, null: false
  end

  create_table "meta_traits", force: :cascade do |t|
    t.integer "resource_id",                limit: 4,     null: false
    t.integer "harvest_id",                 limit: 4,     null: false
    t.integer "trait_id",                   limit: 4
    t.integer "predicate_term_id",          limit: 4,     null: false
    t.integer "object_term_id",             limit: 4
    t.integer "units_term_id",              limit: 4
    t.integer "statistical_method_term_id", limit: 4
    t.integer "removed_by_harvest_id",      limit: 4
    t.string  "trait_resource_pk",          limit: 255,   null: false
    t.string  "measurement",                limit: 255
    t.string  "literal",                    limit: 255
    t.text    "source",                     limit: 65535
  end

  add_index "meta_traits", ["harvest_id"], name: "index_meta_traits_on_harvest_id", using: :btree
  add_index "meta_traits", ["resource_id"], name: "index_meta_traits_on_resource_id", using: :btree

  create_table "nodes", force: :cascade do |t|
    t.integer  "resource_id",               limit: 4,                   null: false
    t.integer  "harvest_id",                limit: 4,                   null: false
    t.integer  "page_id",                   limit: 4
    t.integer  "parent_id",                 limit: 4
    t.integer  "scientific_name_id",        limit: 4
    t.integer  "removed_by_harvest_id",     limit: 4
    t.integer  "lft",                       limit: 4
    t.integer  "rgt",                       limit: 4
    t.integer  "depth",                     limit: 4
    t.string   "canonical",                 limit: 255
    t.string   "taxonomic_status_verbatim", limit: 255
    t.string   "resource_pk",               limit: 255
    t.string   "parent_resource_pk",        limit: 255
    t.string   "further_information_url",   limit: 255
    t.string   "rank",                      limit: 255
    t.string   "rank_verbatim",             limit: 255
    t.boolean  "in_unmapped_area",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nodes", ["canonical"], name: "index_nodes_on_canonical", using: :btree
  add_index "nodes", ["depth"], name: "index_nodes_on_depth", using: :btree
  add_index "nodes", ["harvest_id"], name: "index_nodes_on_harvest_id", using: :btree
  add_index "nodes", ["lft"], name: "index_nodes_on_lft", using: :btree
  add_index "nodes", ["parent_id"], name: "index_nodes_on_parent_id", using: :btree
  add_index "nodes", ["resource_id", "resource_pk"], name: "by_resource_and_pk", using: :btree
  add_index "nodes", ["resource_id"], name: "index_nodes_on_resource_id", using: :btree
  add_index "nodes", ["resource_pk"], name: "index_nodes_on_resource_pk", using: :btree
  add_index "nodes", ["rgt"], name: "index_nodes_on_rgt", using: :btree

  create_table "occurrence_metadata", force: :cascade do |t|
    t.integer "harvest_id",        limit: 4
    t.integer "occurence_id",      limit: 4
    t.integer "predicate_term_id", limit: 4
    t.integer "object_term_id",    limit: 4
    t.text    "literal",           limit: 65535
  end

  create_table "occurrences", force: :cascade do |t|
    t.integer "harvest_id",        limit: 4
    t.string  "resource_pk",       limit: 255, null: false
    t.integer "node_id",           limit: 4
    t.string  "node_resource_pk",  limit: 255, null: false
    t.string  "sex_term_id",       limit: 255
    t.string  "lifestage_term_id", limit: 255
  end

  add_index "occurrences", ["resource_pk"], name: "index_occurrences_on_resource_pk", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer "native_node_id", limit: 4, null: false
  end

  create_table "partners", force: :cascade do |t|
    t.string   "name",         limit: 255,                   null: false
    t.string   "abbr",         limit: 16
    t.string   "short_name",   limit: 32,    default: "",    null: false
    t.string   "homepage_url", limit: 255,   default: "",    null: false
    t.text     "description",  limit: 65535,                 null: false
    t.string   "links_json",   limit: 255,   default: "{}",  null: false
    t.boolean  "auto_publish",               default: false, null: false
    t.boolean  "not_trusted",                default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "partners_users", id: false, force: :cascade do |t|
    t.integer "user_id",    limit: 4, null: false
    t.integer "partner_id", limit: 4, null: false
  end

  create_table "refs", force: :cascade do |t|
    t.text     "body",                  limit: 65535
    t.integer  "resource_id",           limit: 4,     null: false
    t.integer  "harvest_id",            limit: 4,     null: false
    t.string   "resource_pk",           limit: 255,   null: false
    t.string   "url",                   limit: 255
    t.string   "doi",                   limit: 255
    t.integer  "removed_by_harvest_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "refs", ["harvest_id"], name: "index_refs_on_harvest_id", using: :btree
  add_index "refs", ["resource_id", "resource_pk"], name: "index_refs_on_resource_id_and_resource_pk", using: :btree

  create_table "resources", force: :cascade do |t|
    t.integer  "position",                  limit: 4
    t.integer  "min_days_between_harvests", limit: 4,     default: 0,     null: false
    t.integer  "harvest_day_of_month",      limit: 4
    t.integer  "nodes_count",               limit: 4
    t.integer  "partner_id",                limit: 4
    t.string   "harvest_months_json",       limit: 255,   default: "[]",  null: false
    t.string   "name",                      limit: 255,                   null: false
    t.string   "abbr",                      limit: 16
    t.string   "pk_url",                    limit: 255,   default: "$PK", null: false
    t.boolean  "auto_publish",                            default: false, null: false
    t.boolean  "not_trusted",                             default: false, null: false
    t.boolean  "hold_harvesting",                         default: false, null: false
    t.boolean  "might_have_duplicate_taxa",               default: false, null: false
    t.boolean  "force_harvest",                           default: false, null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.text     "description",               limit: 65535
    t.text     "notes",                     limit: 65535
    t.boolean  "is_browsable",                            default: false, null: false
    t.integer  "default_language_id",       limit: 4
    t.integer  "default_license_id",        limit: 4
    t.string   "default_rights_statement",  limit: 300
    t.text     "default_rights_holder",     limit: 65535
    t.integer  "publish_status",            limit: 4
    t.integer  "dataset_license_id",        limit: 4
    t.string   "dataset_rights_holder",     limit: 255
    t.string   "dataset_rights_statement",  limit: 255
  end

  add_index "resources", ["name"], name: "index_resources_on_name", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "scientific_names", force: :cascade do |t|
    t.integer "resource_id",               limit: 4,                    null: false
    t.integer "harvest_id",                limit: 4,                    null: false
    t.integer "node_id",                   limit: 4
    t.integer "normalized_name_id",        limit: 4
    t.integer "parse_quality",             limit: 4
    t.integer "taxonomic_status",          limit: 4
    t.string  "node_resource_pk",          limit: 255
    t.string  "taxonomic_status_verbatim", limit: 255
    t.string  "source_reference",          limit: 255
    t.string  "warnings",                  limit: 255
    t.string  "genus",                     limit: 255
    t.string  "specific_epithet",          limit: 255
    t.string  "infraspecific_epithet",     limit: 255
    t.string  "infrageneric_epithet",      limit: 255
    t.string  "normalized",                limit: 255
    t.string  "canonical",                 limit: 255
    t.string  "uninomial",                 limit: 255
    t.text    "verbatim",                  limit: 65535,                null: false
    t.text    "authorship",                limit: 65535
    t.text    "publication",               limit: 65535
    t.text    "remarks",                   limit: 65535
    t.integer "year",                      limit: 4
    t.boolean "is_preferred"
    t.boolean "is_used_for_merges",                      default: true
    t.boolean "is_publishable",                          default: true
    t.boolean "hybrid"
    t.boolean "surrogate"
    t.boolean "virus"
    t.integer "removed_by_harvest_id",     limit: 4
  end

  add_index "scientific_names", ["harvest_id"], name: "index_scientific_names_on_harvest_id", using: :btree
  add_index "scientific_names", ["node_id"], name: "index_scientific_names_on_node_id", using: :btree
  add_index "scientific_names", ["node_resource_pk"], name: "index_scientific_names_on_node_resource_pk", using: :btree
  add_index "scientific_names", ["normalized"], name: "index_scientific_names_on_normalized", using: :btree
  add_index "scientific_names", ["normalized_name_id"], name: "index_scientific_names_on_normalized_name_id", using: :btree

  create_table "section", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "sections_terms", id: false, force: :cascade do |t|
    t.integer "section_id", limit: 4, null: false
    t.integer "term_id",    limit: 4, null: false
  end

  create_table "terms", force: :cascade do |t|
    t.string  "uri",                     limit: 255,   null: false
    t.string  "name",                    limit: 255
    t.text    "definition",              limit: 65535
    t.text    "comment",                 limit: 65535
    t.text    "attribution",             limit: 65535
    t.boolean "is_hidden_from_overview"
    t.boolean "is_hidden_from_glossary"
  end

  add_index "terms", ["uri"], name: "index_terms_on_uri", using: :btree

  create_table "traits", force: :cascade do |t|
    t.integer "resource_id",                limit: 4,     null: false
    t.integer "parent_id",                  limit: 4
    t.integer "harvest_id",                 limit: 4,     null: false
    t.integer "node_id",                    limit: 4
    t.integer "predicate_term_id",          limit: 4,     null: false
    t.integer "object_term_id",             limit: 4
    t.integer "object_node_id",             limit: 4
    t.integer "units_term_id",              limit: 4
    t.integer "statistical_method_term_id", limit: 4
    t.integer "sex_term_id",                limit: 4
    t.integer "lifestage_term_id",          limit: 4
    t.integer "removed_by_harvest_id",      limit: 4
    t.boolean "of_taxon"
    t.string  "node_resource_pk",           limit: 255
    t.string  "occurrence_resource_pk",     limit: 255
    t.string  "association_resource_pk",    limit: 255
    t.string  "parent_pk",                  limit: 255
    t.string  "resource_pk",                limit: 255,   null: false
    t.string  "measurement",                limit: 255
    t.string  "literal",                    limit: 255
    t.text    "source",                     limit: 65535
  end

  add_index "traits", ["harvest_id"], name: "index_traits_on_harvest_id", using: :btree
  add_index "traits", ["occurrence_resource_pk"], name: "index_traits_on_occurrence_resource_pk", using: :btree
  add_index "traits", ["parent_id"], name: "index_traits_on_parent_id", using: :btree
  add_index "traits", ["resource_id", "resource_pk"], name: "index_traits_on_resource_id_and_resource_pk", using: :btree

  create_table "unit_conversion", force: :cascade do |t|
    t.integer "from_term_id", limit: 4,   null: false
    t.integer "to_term_id",   limit: 4,   null: false
    t.string  "method",       limit: 255, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description", limit: 65535
  end

  create_table "vernaculars", force: :cascade do |t|
    t.integer "resource_id",            limit: 4,     null: false
    t.integer "harvest_id",             limit: 4,     null: false
    t.integer "node_id",                limit: 4
    t.integer "language_id",            limit: 4,     null: false
    t.string  "node_resource_pk",       limit: 255
    t.string  "verbatim",               limit: 255
    t.string  "language_code_verbatim", limit: 255
    t.string  "locality",               limit: 255
    t.string  "source_reference",       limit: 255
    t.text    "remarks",                limit: 65535
    t.boolean "is_preferred"
    t.integer "removed_by_harvest_id",  limit: 4
  end

  add_index "vernaculars", ["harvest_id"], name: "index_vernaculars_on_harvest_id", using: :btree
  add_index "vernaculars", ["resource_id", "verbatim"], name: "index_vernaculars_on_resource_id_and_verbatim", using: :btree
  add_index "vernaculars", ["verbatim"], name: "index_vernaculars_on_verbatim", using: :btree

end
