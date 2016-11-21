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
      t.timestamps, null: false
      # TODO: deafult licensure
      # TODO: deafult values
    end

    create_table :resources do |t|
      t.integer :site_id, null: false
      t.integer :site_pk
      # position for sorting. Lower position means high-priority harvesting
      t.integer :position
      t.integer :min_days_between_harvests, null: false, default: 0
      # If harvest_day_of_month is null, use min_days_between_harvests
      t.integer :harvest_day_of_month
      t.integer :last_harvest_minutes
      t.integer :nodes_count
      # harvest_months_json is an array of month numbers (1 is January) to run
      # harvests; empty means "any month is okay"
      t.string :harvest_months_json, null: false, default: "[]"
      t.string :name, null: false
      t.string :abbr, null: false
      # harvest_from could be a URL or a path; the code must check.
      t.string :harvest_from, null: false
      t.string :pk_url, null: false, default: "$PK"
      t.boolean :auto_publish, null: false, default: false
      t.boolean :not_trusted, null: false, default: false
      t.boolean :stop_harvesting, null: false, default: false
      t.boolean :has_duplicate_taxa, null: false, default: false
      t.boolean :force_harvest, null: false, default: false
      t.timestamps, null: false
      # TODO: deafult licensure
      # TODO: deafult values
    end

    create_table :harvests do |t|
      t.integer :resource_id, null: false
      t.datetime :created_at
      t.datetime :completed_at
      t.string :filename
      t.string :normalized_filename
      t.string :path
      t.string :stage # enumeration
      t.string :file_type
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end

    create_table :hlogs do |t|
      t.integer :harvest_id, null: false
      t.string :type # enumeration
      t.string :message
      t.text :backtrace
      t.integer :line
      t.datetime :created_at
    end

    # TODO: all of the content. It's a copy/paste, I'm skipping it for now.

    create_table :nodes do |t|
      t.integer :resource_id, null: false
      t.integer :page_id, comment: "null means unassigned, of course"
      t.integer :site_pk
      t.integer :parent_id, null: false, default: 0
      t.integer :normalized_name_id, null: false
      t.string :resource_pk
      # rank is a _normalized_ rank string... really an enumeration
      t.string :rank
      # original_rank is whatever rank string they actually used:
      t.string :original_rank
      # TODO: is this the same as literature_references?
      t.string :remarks
    end

    create_table :names do |t|
      t.integer :resource_id, null: false
      t.integer :node_id, null: false
      t.integer :normalized_name_id
      t.string :verbatim
      t.string :warnings
      t.string :genus
      t.string :specific_epithet
      t.string :authorship
      t.integer :year
      t.boolean :hybrid
      t.boolean :surrogate
      t.boolean :virus
    end

    # This gives us a way to say "these names are considered 'the same'."
    create_table :normalized_names do |t|
      t.string :string
      t.string :canonical
    end

    create_table :traits do |t|
      t.integer :resource_id, null: false
      t.integer :node_id, null: false
      t.integer :site_pk, null: false
      t.string :resource_pk
      # Can't have a default, so you should make sure this is at least "{}"
      t.text :metadata_json, null: false
    end

    create_table :measurements do |t|
      t.integer :trait_id, null: false
      t.integer :resource_id, null: false
      # Some measurements are measurements of measurements (but not many), i.e.:
      # of_taxon = false
      t.integer :parent_id, null: false
      # predicate AKA "measurementType"
      t.string :predicate
      t.string :units
      t.string :resource_pk
      t.string :value
    end

    create_table :traits do |t|
      t.integer :resource_id, null: false
      t.integer :node_id, null: false
      t.integer :site_pk, null: false
      t.string :resource_pk
      # Can't have a default, so you should make sure this is at least "{}"
      t.text :metadata_json, null: false
    end

    create_table :measurements do |t|
      t.integer :trait_id, null: false
      t.integer :resource_id, null: false
      # Some measurements are measurements of measurements (but not many), i.e.:
      # of_taxon = false
      t.integer :parent_id, null: false
      # predicate AKA "measurementType"
      t.string :predicate
      t.string :units
      t.string :resource_pk
      t.string :value
    end

    create_table :associations do |t|
      t.integer :trait_id, null: false
    end

    create_table :references do |t|
      t.integer :resource_id, null: false
      t.integer :site_pk, null: false
      t.string :resource_pk
      t.string :description
    end

    # Nodes, measurements, and contents can have references...
    create_table :data_references do |t|
      t.integer :reference_id, null: false
      t.integer :data_id, null: false
      t.string :data_type, null: false
    end

    create_table :tables do |t|
      t.integer :resource_id, null: false
      t.integer :header_lines, null: false, default: 1
      t.string :field_sep, limit: 4
      t.string :line_sep, limit: 4
      # type indicates what kind of contents there are in the file, e.g.:
      # http://eol.org/schema/media/Document for articles.
      t.string :type, null: false
      t.boolean :utf8, null: false, default: false
    end

    create_table :fields do |t|
      t.integer :table_id, null: false
      t.integer :position, null: false
      t.string :term
    end

    # There is almost _always_ only one file per type, but just in case we get
    # some huge resource that wants to break things up into separate files, we
    # can handle that:
    create_table :file_locs do |t|
      t.integer :table_id
      t.string :location
    end

    # TODO: NAMES!
  end
end
