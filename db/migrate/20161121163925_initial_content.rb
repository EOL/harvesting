class InitialContent < ActiveRecord::Migration
  def change
    # NOTE: Quite a few indexes on this table! :S
    create_table :nodes do |t|
      t.integer :resource_id, null: false, index: true
      t.integer :harvest_id, null: false, index: true
      t.integer :page_id, comment: 'null means unassigned, of course'
      t.integer :parent_id, index: true, comment: 'null should only be temporary; populated after propagation.'
      t.integer :scientific_name_id, comment: 'null should only be temporary; populated after propagation.'
      t.integer :removed_by_harvest_id
      t.integer :lft, index: true
      t.integer :rgt, index: true
      t.integer :depth

      t.string :canonical # NOTE: I removed an index here to try and speed up writes.
      t.string :taxonomic_status_verbatim
      t.string :resource_pk, index: true
      t.string :parent_resource_pk, comment: 'to be resolved as needed'
      t.string :further_information_url
      t.string :rank, comment: 'like an enumeration, but requires more flexibility than one would allow'
      t.string :rank_verbatim

      t.boolean :in_unmapped_area, default: false, comment: 'True if the native_node_id is NOT in the EOL hierarchy.'

      t.timestamps
    end
    add_index :nodes, [:resource_id, :resource_pk], name: 'by_resource_and_pk'

    create_table :identifiers do |t|
      t.integer :resource_id, null: false
      t.integer :harvest_id, null: false, index: true
      t.integer :node_id, index: true, comment: "will be populated from node_resource_pk; shouldn't be nil after that."
      t.string :identifier, index: true, comment: "Indexed to assist in names-matching, if possible."
      t.string :node_resource_pk, index: true, comment: "once the node_id is populated, you shouldn't need this."
    end

    create_table :scientific_names do |t|
      t.integer :resource_id, null: false
      t.integer :harvest_id, null: false, index: true
      t.integer :node_id, index: true, comment: "will be populated from node_resource_pk; shouldn't be nil after that."
      t.integer :normalized_name_id, index: true
      t.integer :parse_quality
      # This list was captured from the document Katja produced (this link may
      # not work for all):
      # https://docs.google.com/spreadsheets/d/1qgjUrFQQ8JHLtcVcZK7ClV3mlcZxxObjb5SXkr5FAUUqrr
      t.integer :taxonomic_status, comment: 'Enum: preferred, provisionally_accepted, synonym, alternative, unusable'

      t.string :node_resource_pk, index: true, comment: "once the node_id is populated, you shouldn't need this."
      t.string :taxonomic_status_verbatim
      # The following are strings from GNA:
      t.string :warnings
      t.string :genus
      t.string :specific_epithet
      t.string :infraspecific_epithet
      t.string :infrageneric_epithet
      t.string :normalized, index: true, comment: 'indexed to improve names-matching, but nill until GNA runs!'
      t.string :canonical
      t.string :uninomial

      t.text :verbatim, null: false
      t.text :authorship
      t.text :publication
      t.text :remarks

      # The year is from GNA:
      t.integer :year

      t.boolean :is_preferred
      t.boolean :is_used_for_merges, default: true
      t.boolean :is_publishable, default: true
      # The following are booleans from GNA:
      t.boolean :hybrid
      t.boolean :surrogate
      t.boolean :virus
      t.integer :removed_by_harvest_id
    end

    create_table :vernaculars do |t|
      t.integer :resource_id, null: false
      t.integer :harvest_id, null: false, index: true
      t.integer :node_id, comment: 'only temporarily nil'
      t.integer :language_id, null: false
      t.string :node_resource_pk
      t.string :verbatim, index: true, comment: 'indexed because this is effectively the "resource_pk"'
      t.string :language_code_verbatim
      t.string :locality
      t.text :remarks
      t.text :source
      t.boolean :is_preferred
      t.integer :removed_by_harvest_id
    end
    add_index :vernaculars, [:resource_id, :verbatim]

    # These are citations made by the partner, citing sources used to synthesize
    # that content. These show up below the content (only applies to articles);
    # this is effectively a 'section' of the content; it's part of the object.
    create_table :references do |t|
      t.text :body, comment: 'html; can be *quite* large (over 10K chrs)'
      t.integer :resource_id, null: false
      t.integer :harvest_id, null: false, index: true
      t.string :resource_pk, null: false
      t.string :url
      t.string :doi
      t.integer :removed_by_harvest_id
      t.timestamps null: false
    end
    add_index :references, [:resource_id, :resource_pk]

    create_table :data_references do |t|
      t.integer :reference_id, null: false
      t.references :data, polymorphic: true, index: true, null: false,
        comment: 'Nodes, measurements, and contents can have data_references.'
    end

    create_table :media do |t|
      t.string :guid, null: false, index: true
      t.string :resource_pk, null: false, comment: 'was: identifier'
      t.string :node_resource_pk, null: false, comment: 'null only temporarily'
      t.string :unmodified_url, comment: 'This is the unmodified, original image that we store locally; includes '\
        'extension (unlike base_url)'
      t.string :name_verbatim, comment: 'was: title'
      t.string :name, comment: 'was: title, we will sanitize and restrict HTML and normalize this'
      t.string :source_page_url, comment: 'This is where the "view original" link takes you (could be an remote image '\
        'or a webpage)'
      t.string :source_url, comment: 'This is the URL where fetch the image from.'
      t.string :base_url, comment: 'for images, you will add size info to this; was: object_url'
      t.string :rights_statement, comment: 'will be displayed before the usage_statement'
      t.string :usage_statement, comment: 'will be displayed after the rights_statement'
      t.string :sizes, comment: 'a JSON hash of available sizes, e.g.: { "80x80": "80x71" }'
      t.string :bibliographic_citation_fk, comment: 'will be populated during normalization'

      t.integer :subclass, null: false, default: 0, index: true, comment: 'enum: image, video, sound, map_image, map_js'
      t.integer :format, null: false, default: 0, comment: 'enum: jpg, youtube, flash, vimeo, mp3, ogg, wav'

      t.integer :resource_id, null: false, index: true
      t.integer :harvest_id, null: false, index: true
      t.integer :node_id, index: true
      t.integer :license_id
      t.integer :language_id
      t.integer :location_id
      t.integer :w
      t.integer :h
      t.integer :crop_x_pct, comment: 'stored as a percentage of the width'
      t.integer :crop_y_pct, comment: 'stored as a percentage of the width'
      t.integer :crop_w_pct, comment: 'stored as a percentage of the width'
      t.integer :crop_h_pct, comment: 'stored as a percentage of the width'
      t.integer :bibliographic_citation_id

      t.text :owner, comment: 'html; was rights_holder; current longest is 493; if missing, *must* be '\
        'populated with another attribution agent or the resource name: we MUST show an owner'
      t.text :description_verbatim, comment: 'assumed to be dirty html'
      t.text :description, comment: 'sanitized html; run through namelinks'
      t.text :derived_from

      t.integer :removed_by_harvest_id
      t.datetime :downloaded_at
      t.timestamps null: false
    end
    add_index :media, [:resource_id, :resource_pk]

    create_join_table :media, :sections

    create_table :licenses do |t|
      t.string :name, null: false, comment: "was: title; either for Globalize or I18n key"
      t.string :source_url
      t.string :icon_url
      t.boolean :can_be_chosen_by_partners, null: false, default: false

      t.timestamps null: false
    end

    # TODO: do we DOWNLOAD articles? I don't think so...
    create_table :articles do |t|
      t.string :guid, null: false, index: true
      t.string :resource_pk, null: false, comment: 'was: identifier'

      t.integer :resource_id, null: false, index: true
      t.integer :harvest_id, null: false, index: true
      t.integer :license_id, null: false
      t.integer :language_id
      t.integer :location_id
      t.integer :stylesheet_id
      t.integer :javascript_id
      t.integer :bibliographic_citation_id

      t.text :owner, null: false, comment: 'html; was rights_holder; current longest is 493; if missing, *must* be '\
          'populated with another attribution agent or the resource name: we MUST show an owner'

      t.string :name, comment: 'was: title'
      t.string :source_url
      t.text :body, null: false, comment: 'html; run through namelinks; was description_linked'

      t.integer :removed_by_harvest_id
      t.timestamps null: false
    end
    add_index :articles, [:resource_id, :resource_pk]

    create_join_table :articles, :sections

    # TODO: not sure about the icon (it's not here yet)
    create_table :links do |t|
      t.string :guid, null: false, index: true
      t.string :resource_pk, null: false, comment: 'was: identifier'

      t.integer :resource_id, null: false, index: true
      t.integer :harvest_id, null: false, index: true
      t.integer :language_id

      t.string :name, comment: 'was: title'
      t.string :source_url
      t.text :description, null: false,
        comment: 'html; run through namelinks; was description_linked'

      t.integer :removed_by_harvest_id
      t.timestamps null: false
    end
    add_index :links, [:resource_id, :resource_pk]

    create_join_table :links, :sections

    # There are currently 1,084,941 published data objects with a non-empty
    # citation, out of 7,785,934 objects. Of those, there is a lot of
    # duplication, so I'm making this its own table.
    #
    # If you want to cite this article on EOL, use this citation. It describes
    # 'this content.' Appears in the attribution information for the content.
    create_table :bibliographic_citations do |t|
      t.text :body, comment: 'html; can be *quite* large (over 10K chrs)'

      t.timestamps null: false
    end

    # NOTE that we cannot use "regular" join tables because the IDs will be null on first run; we populate them based on
    # the fks, later.
    create_table :articles_references do |t|
      t.integer :harvest_id, index: true
      t.integer :article_id, index: true
      t.integer :reference_id, index: true
      t.string :ref_resource_fk, null: false, comment: 'to be replaced during normalization'
      t.string :article_resource_fk, null: false, comment: 'to be replaced during normalization'
    end

    create_table :media_references do |t|
      t.integer :harvest_id, index: true
      t.integer :medium_id, index: true
      t.integer :reference_id, index: true
      t.string :ref_resource_fk, null: false, comment: 'to be replaced during normalization'
      t.string :medium_resource_fk, null: false, comment: 'to be replaced during normalization'
    end

    create_table :nodes_references do |t|
      t.integer :harvest_id, index: true
      t.integer :node_id, index: true
      t.integer :reference_id, index: true
      t.string :ref_resource_fk, null: false, comment: 'to be replaced during normalization'
      t.string :node_resource_fk, null: false, comment: 'to be replaced during normalization'
    end

    create_table :scientific_names_references do |t|
      t.integer :harvest_id, index: true
      t.integer :scientific_name_id, index: true
      t.integer :reference_id, index: true
      t.string :ref_resource_fk, null: false, comment: 'to be replaced during normalization'
      t.string :name_resource_fk, null: false, comment: 'to be replaced during normalization'
    end

    create_table :traits_references do |t|
      t.integer :harvest_id, index: true
      t.integer :trait_id, index: true
      t.integer :reference_id, index: true
      t.string :ref_resource_fk, null: false, comment: 'to be replaced during normalization'
      t.string :trait_resource_fk, null: false, comment: 'to be replaced during normalization'
    end

    create_table :associations_references do |t|
      t.integer :harvest_id, index: true
      t.integer :association_id, index: true
      t.integer :reference_id, index: true
      t.string :ref_resource_fk, null: false, comment: 'to be replaced during normalization'
      t.string :association_resource_fk, null: false, comment: 'to be replaced during normalization'
    end

    create_table :roles do |t|
      t.string :name, null: false, comment: 'passed to I18n.t'

      t.timestamps null: false
    end

    create_table :attributions_contents do |t|
      t.integer :attribution_id, null: false, index: true
      t.references :content, polymorphic: true, index: true, null: false
      t.integer :role_id, null: false, index: true
    end

    create_table :attributions do |t|
      t.integer :resource_id, null: false
      t.integer :harvest_id, null: false, index: true
      t.string :resource_pk, null: false
      t.string :name
      t.string :email
      t.text :value, null: false, comment: 'html'

      t.integer :removed_by_harvest_id
      t.timestamps null: false
    end
    add_index :attributions, [:resource_id, :resource_pk]

    create_table :locations do |t|
      t.string :lat_literal
      t.string :long_literal
      t.string :alt_literal
      t.string :locality
      t.string :created
      t.decimal :lat, precision: 64, scale: 12
      t.decimal :long, precision: 64, scale: 12
      t.decimal :alt, precision: 64, scale: 12
    end

    create_table :terms do |t|
      t.string :uri, null: false, index: true
      t.string :name
      t.text :definition
      t.text :comment
      t.text :attribution
      t.boolean :is_hidden_from_overview
      t.boolean :is_hidden_from_glossary
    end

    create_join_table :sections, :terms

    create_table :traits do |t|
      t.integer :resource_id, null: false, comment: 'Supplier'
      t.integer :parent_id, index: true, comment: 'Allows metadata in the form of primary traits'
      t.integer :harvest_id, null: false, index: true
      t.integer :node_id, comment: 'cannot be null AFTER ID reconciliation; will be before'
      t.integer :predicate_term_id, null: false
      t.integer :object_term_id
      t.integer :object_node_id
      t.integer :units_term_id
      t.integer :statistical_method_term_id
      t.integer :sex_term_id
      t.integer :lifestage_term_id
      t.integer :removed_by_harvest_id

      t.boolean :of_taxon, comment: 'temporary; used during ID resolution.'

      t.string :node_resource_pk, comment: 'temporary; will be replaced by object_node_id once IDs are resolved.'
      t.string :occurrence_resource_pk, index: true, comment: 'used to add occurrence metadata.'
      t.string :association_resource_pk, comment: 'temporary; will be used to find object_node_id'
      t.string :parent_pk, comment: 'temporary; will be used to move this to meta_traits'
      t.string :resource_pk, null: false
      t.string :measurement
      t.string :literal

      t.text :source
    end
    add_index :traits, [:resource_id, :resource_pk]

    create_table :meta_traits do |t|
      t.integer :resource_id, null: false, comment: 'Supplier', index: true
      t.integer :harvest_id, null: false, index: true
      t.integer :trait_id, comment: 'temporarily null, added during ID resolution'
      t.integer :predicate_term_id, null: false
      t.integer :object_term_id
      t.integer :units_term_id
      t.integer :statistical_method_term_id # Unused at publishing layer; okay to implement post-MVP TODO
      t.integer :removed_by_harvest_id

      t.string :trait_resource_pk, null: false
      t.string :measurement
      t.string :literal

      t.text :source
    end

    create_table :associations do |t|
      t.integer :trait_id, null: false
    end
  end
end
