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

ActiveRecord::Schema.define(version: 20151111201329) do

  create_table "associations", force: :cascade do |t|
    t.integer "trait_id", limit: 4, null: false
  end

  create_table "contents", force: :cascade do |t|
    t.integer  "resource_id",  limit: 4,   null: false
    t.integer  "partner_id",   limit: 4,   null: false
    t.integer  "site_pk",      limit: 4
    t.integer  "language_id",  limit: 4
    t.integer  "info_item_id", limit: 4
    t.string   "resource_pk",  limit: 255
    t.string   "type",         limit: 32
    t.string   "title",        limit: 255
    t.string   "body",         limit: 255
    t.float    "lat",          limit: 24
    t.float    "long",         limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_references", force: :cascade do |t|
    t.integer "reference_id", limit: 4,   null: false
    t.integer "data_id",      limit: 4,   null: false
    t.string  "data_type",    limit: 255, null: false
  end

  create_table "errors", force: :cascade do |t|
    t.integer "harvest_id",  limit: 4,     null: false
    t.string  "filename",    limit: 255
    t.string  "description", limit: 255
    t.text    "backtrace",   limit: 65535
    t.integer "line",        limit: 4
  end

  create_table "fields", force: :cascade do |t|
    t.integer "table_id", limit: 4,   null: false
    t.integer "position", limit: 4,   null: false
    t.string  "term",     limit: 255
  end

  create_table "file_locs", force: :cascade do |t|
    t.integer "table_id", limit: 4
    t.string  "location", limit: 255
  end

  create_table "harvests", force: :cascade do |t|
    t.integer  "resource_id",  limit: 4, null: false
    t.datetime "created_at"
    t.datetime "completed_at"
  end

  create_table "measurements", force: :cascade do |t|
    t.integer "trait_id",      limit: 4,                    null: false
    t.integer "resource_id",   limit: 4,                    null: false
    t.integer "parent_id",     limit: 4,                    null: false
    t.boolean "of_taxon",                    default: true, null: false
    t.string  "predicate",     limit: 255
    t.string  "units",         limit: 255
    t.string  "resource_pk",   limit: 255
    t.string  "value",         limit: 255
    t.text    "metadata_json", limit: 65535,                null: false
  end

  create_table "nodes", force: :cascade do |t|
    t.integer "resource_id",    limit: 4,                  null: false
    t.integer "site_pk",        limit: 4
    t.integer "parent_id",      limit: 4,   default: 0,    null: false
    t.string  "resource_pk",    limit: 255
    t.string  "rank",           limit: 255
    t.string  "name",           limit: 255,                null: false
    t.string  "remarks",        limit: 255
    t.string  "ancestors_json", limit: 255, default: "{}", null: false
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "references", force: :cascade do |t|
    t.integer "resource_id", limit: 4,   null: false
    t.integer "site_pk",     limit: 4,   null: false
    t.string  "resource_pk", limit: 255
    t.string  "description", limit: 255
  end

  create_table "resources", force: :cascade do |t|
    t.integer  "site_id",                   limit: 4,   default: 1,     null: false
    t.integer  "site_pk",                   limit: 4
    t.integer  "position",                  limit: 4
    t.integer  "min_days_between_harvests", limit: 4,   default: 0,     null: false
    t.integer  "harvest_day_of_month",      limit: 4
    t.integer  "last_harvest_minutes",      limit: 4
    t.integer  "nodes_count",               limit: 4
    t.string   "harvest_months_json",       limit: 255, default: "[]",  null: false
    t.string   "name",                      limit: 255,                 null: false
    t.string   "harvest_from",              limit: 255,                 null: false
    t.string   "pk_url",                    limit: 255, default: "$PK", null: false
    t.boolean  "auto_publish",                          default: false, null: false
    t.boolean  "not_trusted",                           default: false, null: false
    t.boolean  "stop_harvesting",                       default: false, null: false
    t.boolean  "has_duplicate_taxa",                    default: false, null: false
    t.boolean  "force_harvest",                         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tables", force: :cascade do |t|
    t.integer "resource_id",  limit: 4,                   null: false
    t.integer "header_lines", limit: 4,   default: 1,     null: false
    t.string  "field_sep",    limit: 4
    t.string  "line_sep",     limit: 4
    t.string  "type",         limit: 255,                 null: false
    t.boolean "utf8",                     default: false, null: false
  end

  create_table "traits", force: :cascade do |t|
    t.integer "resource_id",   limit: 4,     null: false
    t.integer "node_id",       limit: 4,     null: false
    t.integer "site_pk",       limit: 4,     null: false
    t.string  "resource_pk",   limit: 255
    t.text    "metadata_json", limit: 65535, null: false
  end

end
