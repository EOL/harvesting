# This is really long: sorry. Getting all the inital ideas in one place is, IMO,
# valuable, though.
class InitialSchema < ActiveRecord::Migration
  def change
    # NOTE: skipping a "sites" table, because the harvester doesn't really care
    # about that information. It simply needs the ID.
    create_table :partners do |t|
      # The ID of the remote EOL site that created this partner:
      t.integer :site_id, null: false, default: Rails.configuration.site_id
      # The PK that the remote site uses for this partner. ...This allows us to
      # use our own simple, local IDs; when we're talking to a remote site, we
      # can use these IDs, but by and large, we don't actually need them! Null
      # IS allowed, and implies "there is no PK, just use our local ID."
      t.integer :site_pk
      t.string :name, null: false
      t.string :acronym, null: false, limit: 16, default: ""
      t.string :short_name, null: false, limit: 32, default: ""
      t.string :url, null: false, default: ""
      t.text :description, null: false
      # links_json used for creating arbitrary pairs of link names/urls:
      t.string :links_json, null: false, default: "{}"
      # auto_publish applies to _all_ resources!
      t.boolean :auto_publish, null: false, default: false
      # not_trusted applies to _all_ resources!
      t.boolean :not_trusted, null: false, default: false
      t.timestamps null: false
      # TODO: deafult licensure
      # TODO: deafult values
    end

    create_table :resources do |t|
      t.integer :site_id, null: false
      # position for sorting. Lower position means high-priority harvesting
      t.integer :position
      t.integer :min_days_between_harvests, null: false, default: 0
      # If harvest_day_of_month is null, use min_days_between_harvests
      t.integer :harvest_day_of_month
      t.integer :nodes_count
      t.string :site_pk
      # harvest_months_json is an array of month numbers (1 is January) to run
      # harvests; empty means "any month is okay"
      t.string :harvest_months_json, null: false, default: "[]"
      t.string :name, null: false, index: true,
        comment: "indexed to facilitate sorting by name"
      t.string :abbr, null: false
      t.string :pk_url, null: false, default: "$PK"
      t.boolean :auto_publish, null: false, default: false
      t.boolean :not_trusted, null: false, default: false
      t.boolean :hold_harvesting, null: false, default: false
      t.boolean :has_duplicate_taxa, null: false, default: false
      t.boolean :force_harvest, null: false, default: false
      t.timestamps null: false
      # TODO: deafult licensure
      # TODO: deafult values
    end

    create_table :formats do |t|
      t.integer :resource_id, null: false
      t.integer :harvest_id,
        comment: "if null, only associated to resource, and is 'abstract'"
      t.integer :sheet, null: false, default: 1,
        comment: "which sheet to read, if it's in a multi-sheet file"
      t.integer :header_lines, null: false, default: 1
      t.integer :data_begins_on_line, null: false, default: 1
      # NOTE: this is removed in a later harvest.
      t.integer :position,
        comment: "Because each file should be read in a specific order..."
      # NOTE: default is the first value, in this case, excel.
      t.integer :file_type, comment: "enum: excel, csv", default: 0
      # represents e.g.: :articles for http://eol.org/schema/media/Document
      t.integer :represents, null: false,
        comment: "enum: articles, attributions, images, js_maps, links, media, "\
          "maps, refs, sounds, videos, nodes, vernaculars, scientific_names, data"
      t.string :get_from, null: false,
        comment: "may be remote URL or full file system path"
      t.string :file, comment: "full path"
      t.string :diff, comment: "full path to file diff'ed from previous version"
      t.string :field_sep, limit: 4, default: ","
      t.string :line_sep, limit: 4, default: "\n"
      t.boolean :utf8, null: false, default: false
    end

    create_table :fields do |t|
      t.integer :format_id, null: false
      t.integer :position, null: false
      t.integer :validation,
        comment: "enum: must_be_integers, must_be_numerical, must_know_uris"
      t.integer :mapping,
        comment: "Enum: (but values TBD) ... can replace map_to_field or be used for transforms"
      t.integer :special_handling,
        comment: "Enum: (but values TBD) these allow post-filtering specific to 'trouble' resources, after mapping is applied"
      t.string :submapping,
        comment: "used for to_attribution and to_ancestor mappings to assign the proper association (role or rank); null by default"
      t.string :expected_header,
        comment: "Does NOT need to literally match, but produces a warning if it doesn't (with some slop allowed)"
      t.boolean :unique_in_format, default: false, null: false
      t.boolean :can_be_empty, default: true, null: false
    end

    create_table :harvests do |t|
      t.integer :resource_id, null: false
      t.integer :time_in_minutes
      t.boolean :hold, null: false, default: false
      t.datetime :fetched_at
      t.datetime :validated_at
      t.datetime :deltas_created_at
      t.datetime :stored_at
      t.datetime :consistency_checked_at
      t.datetime :names_parsed_at
      t.datetime :nodes_matched_at
      t.datetime :ancestry_built_at
      t.datetime :units_normalized_at
      t.datetime :linked_at
      t.datetime :indexed_at
      t.datetime :failed_at
      t.datetime :completed_at
      t.timestamps null: false
    end

    create_table :hlogs do |t|
      t.integer :harvest_id, null: false
      t.integer :format_id, null: false
      t.integer :category,
        comment: "Enum: errors, warns, infos, progs, loops, starts, ends, counts, queries"
      t.string :message
      t.text :backtrace
      t.integer :line
      t.datetime :created_at
    end

    create_table :languages do |t|
      t.string :code, comment: "iso_639_3"
      t.string :group_code, comment: "iso_639_2"
    end

    create_table :pages do |t|
      t.integer :native_node_id, null: false
    end

    create_table :section do |t|
      t.string :name
    end

    # This gives us a way to say "these names are considered 'the same'."
    create_table :normalized_names do |t|
      t.string :string
      t.string :canonical
    end

    create_table :media_download_error do |t|
      t.integer :content_id, null: false, index: true
      t.text :message
      t.timestamps null: false
    end

    create_table :unit_conversion do |t|
      t.integer :from_term_id, null: false
      t.integer :to_term_id, null: false
      t.string :method, null: false,
        comment: "WARNING! this is *executable* Ruby code. Lock it down."
    end

    # NOTE: resource content will be handled in a separate migration, since they
    # seem a salient "piece" of things.
  end
end
