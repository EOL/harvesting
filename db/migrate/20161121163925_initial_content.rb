class InitialContent < ActiveRecord::Migration
  def change
    create_table :section do |t|
      t.string :name
    end

    create_table :media do |t|
      t.string :guid, null: false, index: true
      t.string :resource_pk, null: false, comment: "was: identifier"
      t.string :unmodified_url,
        comment: "This is the unmodified, original image that we store locally; includes extension (unlike base_url)"
      t.string :name_verbatim, comment: "was: title"
      t.string :name, comment: "was: title, we will sanitize and restrict HTML and normalize this"
      t.string :source_page_url,
        comment: "This is where the 'view original' link takes you (could be an remote image or a webpage)"
      t.string :source_url
      t.string :base_url, null: false,
        comment: "for images, you will add size info to this; was: object_url"
      t.string :rights_statement

      t.integer :subclass, null: false, default: 0, index: true,
        comment: "enum: image, video, sound, map, js_map"
      t.integer :format, null: false, default: 0,
        comment: "enum: jpg, youtube, flash, vimeo, mp3, ogg, wav"

      t.integer :resource_id, null: false, index: true
      t.integer :license_id, null: false
      t.integer :language_id
      t.integer :location_id
      t.integer :stylesheet_id
      t.integer :javascript_id
      t.integer :bibliographic_citation_id

      t.text :owner, null: false,
        comment: "html; was rights_holder; current longest is 493; if missing, *must* be populated "\
          "with another attribution agent or the resource name: we MUST show an owner"
      t.text :description_verbatim, comment: "assumed to be dirty html"
      t.text :description, comment: "sanitized html; run through namelinks"

      t.datetime :downloaded_at
      t.timestamps null: false
    end

    create_join_table :media, :sections

    create_table :media_download_error do |t|
      t.integer :content_id, null: false, index: true
      t.text :message
      t.timestamps null: false
    end

    # TODO: do we DOWNLOAD articles? I don't think so...
    create_table :articles do |t|
      t.string :guid, null: false, index: true
      t.string :resource_pk, null: false, comment: "was: identifier"

      t.integer :resource_id, null: false, index: true
      t.integer :license_id, null: false
      t.integer :language_id
      t.integer :location_id
      t.integer :stylesheet_id
      t.integer :javascript_id
      t.integer :bibliographic_citation_id

      t.text :owner, null: false,
        comment: "html; was rights_holder; current longest is 493; if missing, *must* be populated "\
          "with another attribution agent or the resource name: we MUST show an owner"

      t.string :name, comment: "was: title"
      t.string :source_url
      t.text :body, null: false,
        comment: "html; run through namelinks; was description_linked"

      t.timestamps null: false
    end

    create_join_table :articles, :sections

    # TODO: not sure about the icon (it's not here yet)
    create_table :links do |t|
      t.string :guid, null: false, index: true
      t.string :resource_pk, null: false, comment: "was: identifier"

      t.integer :resource_id, null: false, index: true
      t.integer :language_id

      t.string :name, comment: "was: title"
      t.string :source_url
      t.text :description, null: false,
        comment: "html; run through namelinks; was description_linked"

      t.timestamps null: false
    end

    create_join_table :links, :sections

    # There are currently 1,084,941 published data objects with a non-empty
    # citation, out of 7,785,934 objects. Of those, there is a lot of
    # duplication, so I'm making this its own table.
    #
    # If you want to cite this article on EOL, use this citation. It describes
    # "this content." Appears in the attribution information for the content.
    create_table :bibliographic_citations do |t|
      t.text :body, comment: "html; can be *quite* large (over 10K chrs)"

      t.timestamps null: false
    end

    create_join_table(:articles, :references) do |t|
      t.index :article_id
    end

    create_table :roles do |t|
      t.string :name, null: false, comment: "passed to I18n.t"

      t.timestamps null: false
    end

    create_table :attributions_contents do |t|
      t.integer :attribution_id, null: false, index: true
      t.references :content, polymorphic: true, index: true, null: false
      t.integer :role_id, null: false, index: true
    end

    create_table :attributions do |t|
      t.string :resource_pk, null: false, index: true
      t.string :name
      t.string :email
      t.text :value, null: false, comment: "html"

      t.timestamps null: false
    end

    create_table :locations do |t|
      t.string :verbatim
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
      t.integer :resource_id, null: false, comment: "Supplier"
      t.integer :node_id, null: false
      t.integer :resource_pk, null: false
      t.integer :object_term_id
      t.integer :object_node_id
      t.integer :units_term_id
      t.integer :normal_units_term_id
      t.integer :statistical_method_term_id
      t.integer :sex_term_id
      t.integer :lifestage_term_id

      t.string :measurement
      t.string :normal_measurement
      t.text :source
      t.string :literal
    end

    create_table :meta_traits do |t|
      t.integer :trait_id, null: false
      t.integer :resource_pk, null: false
      t.integer :object_term_id
      t.integer :units_term_id
      t.integer :normal_units_term_id
      t.integer :statistical_method_term_id

      t.string :measurement
      t.string :normal_measurement
      t.text :source
      t.string :literal
    end

    create_table :associations do |t|
      t.integer :trait_id, null: false
    end

    create_table :unit_conversion do |t|
      t.integer :from_term_id, null: false
      t.integer :to_term_id, null: false
      t.string :method, null: false,
        comment: "WARNING! this is *executable* Ruby code. Lock it down."
    end
  end
end
