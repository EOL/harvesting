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

ActiveRecord::Schema.define(version: 20161121181833) do

  create_table "articles", force: :cascade do |t|
    t.string   "guid",                      limit: 255,   null: false
    t.string   "resource_pk",               limit: 255,   null: false
    t.integer  "resource_id",               limit: 4,     null: false
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
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "articles", ["guid"], name: "index_articles_on_guid", using: :btree
  add_index "articles", ["resource_id"], name: "index_articles_on_resource_id", using: :btree

  create_table "articles_references", id: false, force: :cascade do |t|
    t.integer "article_id",   limit: 4, null: false
    t.integer "reference_id", limit: 4, null: false
  end

  add_index "articles_references", ["article_id"], name: "index_articles_references_on_article_id", using: :btree

  create_table "articles_sections", id: false, force: :cascade do |t|
    t.integer "article_id", limit: 4, null: false
    t.integer "section_id", limit: 4, null: false
  end

  create_table "associations", force: :cascade do |t|
    t.integer "trait_id", limit: 4, null: false
  end

  create_table "attributions", force: :cascade do |t|
    t.integer  "attribution_id", limit: 4,     null: false
    t.integer  "content_id",     limit: 4,     null: false
    t.string   "content_type",   limit: 255,   null: false
    t.integer  "role_id",        limit: 4,     null: false
    t.text     "value",          limit: 65535, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "attributions", ["attribution_id"], name: "index_attributions_on_attribution_id", using: :btree
  add_index "attributions", ["content_type", "content_id"], name: "index_attributions_on_content_type_and_content_id", using: :btree
  add_index "attributions", ["role_id"], name: "index_attributions_on_role_id", using: :btree

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

  create_table "fields", force: :cascade do |t|
    t.integer "table_id", limit: 4,   null: false
    t.integer "position", limit: 4,   null: false
    t.string  "term",     limit: 255
  end

  create_table "file_locs", force: :cascade do |t|
    t.integer "table_id", limit: 4
    t.string  "location", limit: 255
  end

  create_table "formats", force: :cascade do |t|
    t.integer "resource_id",  limit: 4,                   null: false
    t.integer "header_lines", limit: 4,   default: 1,     null: false
    t.string  "filename",     limit: 255
    t.string  "field_sep",    limit: 4
    t.string  "line_sep",     limit: 4
    t.string  "type",         limit: 255,                 null: false
    t.boolean "utf8",                     default: false, null: false
  end

  create_table "harvests", force: :cascade do |t|
    t.integer  "resource_id",         limit: 4,   null: false
    t.datetime "created_at",                      null: false
    t.datetime "completed_at"
    t.string   "filename",            limit: 255
    t.string   "normalized_filename", limit: 255
    t.string   "path",                limit: 255
    t.string   "stage",               limit: 255
    t.string   "file_type",           limit: 255
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "updated_at",                      null: false
  end

  create_table "hlogs", force: :cascade do |t|
    t.integer  "harvest_id", limit: 4,     null: false
    t.string   "type",       limit: 255
    t.string   "message",    limit: 255
    t.text     "backtrace",  limit: 65535
    t.integer  "line",       limit: 4
    t.datetime "created_at"
  end

  create_table "links", force: :cascade do |t|
    t.string   "guid",        limit: 255,   null: false
    t.string   "resource_pk", limit: 255,   null: false
    t.integer  "resource_id", limit: 4,     null: false
    t.integer  "language_id", limit: 4
    t.string   "name",        limit: 255
    t.string   "source_url",  limit: 255
    t.text     "description", limit: 65535, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "links", ["guid"], name: "index_links_on_guid", using: :btree
  add_index "links", ["resource_id"], name: "index_links_on_resource_id", using: :btree

  create_table "links_sections", id: false, force: :cascade do |t|
    t.integer "link_id",    limit: 4, null: false
    t.integer "section_id", limit: 4, null: false
  end

  create_table "media", force: :cascade do |t|
    t.string   "guid",                      limit: 255,               null: false
    t.string   "resource_pk",               limit: 255,               null: false
    t.string   "unmodified_url",            limit: 255
    t.string   "source_page_url",           limit: 255
    t.integer  "subclass",                  limit: 4,     default: 0, null: false
    t.integer  "format",                    limit: 4,     default: 0, null: false
    t.integer  "resource_id",               limit: 4,                 null: false
    t.integer  "license_id",                limit: 4,                 null: false
    t.integer  "language_id",               limit: 4
    t.integer  "location_id",               limit: 4
    t.integer  "stylesheet_id",             limit: 4
    t.integer  "javascript_id",             limit: 4
    t.integer  "bibliographic_citation_id", limit: 4
    t.text     "owner",                     limit: 65535,             null: false
    t.string   "name",                      limit: 255
    t.string   "source_url",                limit: 255
    t.text     "description",               limit: 65535
    t.string   "base_url",                  limit: 255,               null: false
    t.datetime "downloaded_at"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "media", ["guid"], name: "index_media_on_guid", using: :btree
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
    t.integer "trait_id",                   limit: 4,     null: false
    t.integer "resource_pk",                limit: 4,     null: false
    t.integer "object_term_id",             limit: 4
    t.integer "units_term_id",              limit: 4
    t.integer "normal_units_term_id",       limit: 4
    t.integer "statistical_method_term_id", limit: 4
    t.string  "measurement",                limit: 255
    t.string  "normal_measurement",         limit: 255
    t.text    "source",                     limit: 65535
    t.string  "literal",                    limit: 255
  end

  create_table "names", force: :cascade do |t|
    t.integer "resource_id",        limit: 4,   null: false
    t.integer "node_id",            limit: 4,   null: false
    t.integer "normalized_name_id", limit: 4
    t.string  "verbatim",           limit: 255
    t.string  "warnings",           limit: 255
    t.string  "genus",              limit: 255
    t.string  "specific_epithet",   limit: 255
    t.string  "authorship",         limit: 255
    t.integer "year",               limit: 4
    t.boolean "hybrid"
    t.boolean "surrogate"
    t.boolean "virus"
  end

  create_table "nodes", force: :cascade do |t|
    t.integer "resource_id",   limit: 4,               null: false
    t.integer "page_id",       limit: 4
    t.integer "site_pk",       limit: 4
    t.integer "parent_id",     limit: 4,   default: 0, null: false
    t.integer "name_id",       limit: 4,               null: false
    t.string  "verbatim_name", limit: 255,             null: false
    t.string  "resource_pk",   limit: 255
    t.string  "rank",          limit: 255
    t.string  "original_rank", limit: 255
    t.string  "remarks",       limit: 255
  end

  create_table "normalized_names", force: :cascade do |t|
    t.string "string",    limit: 255
    t.string "canonical", limit: 255
  end

  create_table "pages", force: :cascade do |t|
    t.integer "native_node_id", limit: 4, null: false
  end

  create_table "partners", force: :cascade do |t|
    t.integer  "site_id",      limit: 4,     default: 1,     null: false
    t.integer  "site_pk",      limit: 4
    t.string   "name",         limit: 255,                   null: false
    t.string   "acronym",      limit: 16,    default: "",    null: false
    t.string   "short_name",   limit: 32,    default: "",    null: false
    t.string   "url",          limit: 255,   default: "",    null: false
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

  create_table "references", force: :cascade do |t|
    t.text     "body",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "resources", force: :cascade do |t|
    t.integer  "site_id",                   limit: 4,                   null: false
    t.integer  "site_pk",                   limit: 4
    t.integer  "position",                  limit: 4
    t.integer  "min_days_between_harvests", limit: 4,   default: 0,     null: false
    t.integer  "harvest_day_of_month",      limit: 4
    t.integer  "last_harvest_minutes",      limit: 4
    t.integer  "nodes_count",               limit: 4
    t.string   "harvest_months_json",       limit: 255, default: "[]",  null: false
    t.string   "name",                      limit: 255,                 null: false
    t.string   "abbr",                      limit: 255,                 null: false
    t.string   "harvest_from",              limit: 255,                 null: false
    t.string   "pk_url",                    limit: 255, default: "$PK", null: false
    t.boolean  "auto_publish",                          default: false, null: false
    t.boolean  "not_trusted",                           default: false, null: false
    t.boolean  "stop_harvesting",                       default: false, null: false
    t.boolean  "has_duplicate_taxa",                    default: false, null: false
    t.boolean  "force_harvest",                         default: false, null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "section", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "sections_terms", id: false, force: :cascade do |t|
    t.integer "section_id", limit: 4, null: false
    t.integer "term_id",    limit: 4, null: false
  end

  create_table "term", force: :cascade do |t|
    t.string  "uri",                     limit: 255,   null: false
    t.string  "name",                    limit: 255
    t.text    "definition",              limit: 65535
    t.text    "comment",                 limit: 65535
    t.text    "attribution",             limit: 65535
    t.boolean "is_hidden_from_overview"
    t.boolean "is_hidden_from_glossary"
  end

  add_index "term", ["uri"], name: "index_term_on_uri", using: :btree

  create_table "traits", force: :cascade do |t|
    t.integer "resource_id",                limit: 4,     null: false
    t.integer "node_id",                    limit: 4,     null: false
    t.integer "resource_pk",                limit: 4,     null: false
    t.integer "object_term_id",             limit: 4
    t.integer "object_node_id",             limit: 4
    t.integer "units_term_id",              limit: 4
    t.integer "normal_units_term_id",       limit: 4
    t.integer "statistical_method_term_id", limit: 4
    t.integer "sex_term_id",                limit: 4
    t.integer "lifestage_term_id",          limit: 4
    t.string  "measurement",                limit: 255
    t.string  "normal_measurement",         limit: 255
    t.text    "source",                     limit: 65535
    t.string  "literal",                    limit: 255
  end

  create_table "unit_conversion", force: :cascade do |t|
    t.integer "from_term_id", limit: 4,   null: false
    t.integer "to_term_id",   limit: 4,   null: false
    t.string  "method",       limit: 255, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description", limit: 65535
  end

end
