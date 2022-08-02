class WebDb
  class ModelMapper
    SAME_SCI_NAME_ATTRIBUTES =
      %i[italicized genus specific_epithet infraspecific_epithet infrageneric_epithet uninomial verbatim
         authorship publication remarks parse_quality year hybrid surrogate virus]
    # TODO: Stylesheet and Javascript. ...We don't need them yet, sooo...
    SAME_ARTICLE_ATTRIBUTES = %i[guid resource_pk source_url name body source_url]
    SAME_MEDIUM_ATTRIBUTES =
      %i[guid resource_pk source_url name description unmodified_url base_url
         source_page_url rights_statement usage_statement]
    SAME_NODE_ATTRIBUTES = %i[page_id parent_resource_pk in_unmapped_area resource_pk source_url]
    SAME_VERNACULAR_ATTRIBUTES = %i[node_resource_pk locality remarks source]

    ENDS_AS_AN_ARRAY = /]\s*$/m

    def initialize(resource, process)
      @resource = resource
      @process  = process
      @root_url = Rails.application.secrets.repository[:url] || 'http://eol.org'
      @web_resource_id = WebDb.resource_id(@resource)
    end

    def store_old_json(klass, record)
      hash = record_to_hash(klass, record)
      array = if File.exist?(@resource.old_records_path)
        JSON.parse(File.read(@resource.old_records_path))
      else
        []
      end
      raise "JSON was not an array: #{@resource.old_records_path}" unless array.is_a?(Array)
      array << hash
      File.write(@resource.old_records_path, JSON.dump(array))
    end

    def last_line_of_old_records
      last_line = `/usr/bin/tail -n 1 #{@resource.old_records_path}`.chomp
    end

    def record_to_hash(klass, record)
      klass = klass.to_s
      # Giant switch to determine which builder to use
      struct = if klass == 'Node'
        node_to_struct(record)
      elsif klass == 'Reference'
        klass = 'Referent'
        referant_to_struct(record)
      elsif %w[NodesReference TraitsReference AssocsReference MediaReference ArticlesReference].include?(klass)
        reference_to_struct(record)
      elsif klass == 'Attribution'
        attribution_to_struct(record)
      elsif klass == 'BibliographicCitation'
        citation_to_struct(record)
      elsif klass == 'Location'
        location_to_struct(record)
      elsif klass == 'Identifier'
        node = get_node_from_record(record)
        identifier_to_struct(node, record)
      elsif klass == 'NodeAncestor'
        node = get_node_from_record(record)
        node_ancestor_to_struct(node, record)
      elsif klass == 'ScientificName'
        node = get_node_from_record(record)
        scientific_name_to_struct(node, record)
      elsif klass == 'Medium'
        node = get_node_from_record(record)
        medium_to_struct(node, record)
      elsif klass == 'ImageInfo'
        image_info_to_struct(medium)
      elsif klass == 'Article'
        node = get_node_from_record(record)
        article_to_struct(node, record)
      elsif klass == 'Vernacular'
        node = get_node_from_record(record)
        vernacular_to_struct(node, record)
      else
        raise "Cannot serialize: #{pp record}"
      end
      hashed = struct.to_h.delete_if { |k,v| v.nil? }
      hashed[:class] = klass
      hashed
    end

    def get_node_from_record(record)
      if record.respond_to?(:node)
        record.node
      elsif record.respond_to?(:node_id)
        Node.find(record.node_id)
      elsif record&.has_key?[:node_id]
        Node.find(record[:node_id])
      elsif record&.has_key?['node_id']
        Node.find(record['node_id'])
      end
    end

    def node_to_struct(node)
      web_node = Struct::WebNode.new
      copy_fields(SAME_NODE_ATTRIBUTES, node, web_node)
      add_resource_id(web_node)
      add_db_id(web_node, node)
      web_node.canonical_form = clean_values(node.safe_canonical)
      web_node.scientific_name = clean_values(node.safe_scientific)
      web_node.has_breadcrumb = clean_values(!node.no_landmark?)
      web_node.rank_id = WebDb.rank(node.rank, @process)
      web_node.is_hidden = 0
      web_node.landmark = Node.landmarks[node.landmark] # NOTE: we are RELYING on the enum being the same, here!
      web_node
    end

    def referant_to_struct(ref)
      referent = Struct::WebReferent.new
      referent.body = clean_values(ref.body)
      add_resource_id(referent)
      add_db_id(referent, ref)
      referent
    end

    def reference_to_struct(object)
      reference = Struct::WebReference.new
      reference.parent_type = object.class.name
      add_resource_id(reference)
      reference
    end

    def attribution_to_struct(content_attribution)
      attribution = Struct::WebAttribution.new
      attribution.value = clean_values(content_attribution.attribution.body)
      add_resource_id(attribution)
      attribution.resource_pk = clean_values(content_attribution.attribution.resource_pk)
      attribution.content_resource_fk = clean_values(content_attribution.content_resource_fk)
      attribution.content_type = content_attribution.content_type
      attribution.content_id = content_attribution.content_id # NOTE this is the HARVEST DB ID. It will be replaced.
      attribution.role_id = WebDb.role(content_attribution.attribution.role, @process)
      attribution.url = content_attribution.attribution.sanitize_url
      attribution
    end

    def section_to_struct(object, articles_section)
      section = Struct::WebContentSection.new
      add_resource_id(section)
      section.content_id = object.id # NOTE this is the HARVEST DB ID. It will be replaced.
      section.content_type = type
      section.section_id = articles_section.section_id # WE ASSUME THE IDs ARE THE SAME! (q.v.: DefaultSections)
      section
    end

    def citation_to_struct(citation)
      bc = Struct::WebBibliographicCitation.new
      bc.body = clean_values(citation.body)
      add_db_id(bc, citation)
      add_resource_id(bc)
      bc
    end

    def location_to_struct(loc)
      loc_struct = Struct::WebLocation.new
      literal = "#{loc.lat_literal} #{loc.long_literal} #{loc.alt_literal} #{loc.locality}"
      loc_struct.location = literal
      loc_struct.longitude = loc.long
      loc_struct.latitude = loc.lat
      loc_struct.altitude = loc.alt
      loc_struct.spatial_location = loc.locality
      add_resource_id(loc_struct)
      loc_struct
    end

    def identifier_to_struct(node, ider)
      web_id = Struct::WebIdentifier.new
      add_resource_id(web_id)
      add_db_id(web_id, ider)
      web_id.node_resource_pk = clean_values(node.resource_pk)
      web_id.identifier = ider.identifier
      web_id
    end

    def node_ancestor_to_struct(node, nodan)
      anc = Struct::WebNodeAncestor.new
      add_resource_id(anc)
      anc.node_resource_pk = clean_values(node.resource_pk)
      anc.ancestor_resource_pk = clean_values(nodan.ancestor_fk)
      anc.depth = nodan.depth
      add_db_id(anc, nodan) # TODO: I'm not sure this is required?
      anc
    end

    def scientific_name_to_struct(node, name_model)
      name_struct = Struct::WebScientificName.new
      name_struct.page_id = node.page_id
      add_db_id(name_struct, name_model)
      name_struct.canonical_form = clean_values(name_model.canonical_italicized)
      name_struct.taxonomic_status_id = WebDb.taxonomic_status(name_model.taxonomic_status_verbatim&.downcase, @process)
      name_struct.is_preferred = clean_values(name_model.is_preferred)
      add_resource_id(name_struct)
      name_struct.node_resource_pk = name_model.resource_pk.blank? ? clean_values(node.resource_pk) :
        clean_values(name_model.resource_pk)
      # name_struct.source_reference = name_model. ...errr.... TODO: This is intended to move off of the node. Put it
      # here!
      name_struct.attribution = clean_values(name_model.attribution_html)
      name_struct.dataset_name = clean_values(name_model.dataset_name)
      name_struct.name_according_to = clean_values(name_model.name_according_to)
      copy_fields(SAME_SCI_NAME_ATTRIBUTES, name_model, name_struct)
      name_struct
    end

    def medium_to_struct(node, medium)
      web_medium = Struct::WebMedium.new
      web_medium.page_id = node.page_id
      add_db_id(web_medium, medium)
      web_medium.subclass = Medium.subclasses[medium.subclass]
      web_medium.format = Medium.formats[medium.format]
      web_medium.owner = medium.owner
      # TODO: ImageInfo from medium.sizes
      copy_fields(SAME_MEDIUM_ATTRIBUTES, medium, web_medium)
      add_resource_id(web_medium)
      web_medium.name = clean_values(medium.name_verbatim) if medium.name.blank?
      web_medium.description = clean_values(medium.description_verbatim) if medium.description.blank?
      web_medium.base_url = fixed_medium_url(medium, 'base')
      web_medium.unmodified_url = fixed_medium_url(medium, 'unmodified')
      web_medium.license_id = WebDb.license(medium.license&.source_url, @process)
      web_medium.language_id = WebDb.language(medium.language, @process)
      web_medium
    end

    def image_info_to_struct(medium)
      ii = Struct::WebImageInfo.new
      add_resource_id(ii)
      ii.original_size = "#{medium.w}x#{medium.h}" if medium.w && medium.h
      unless medium.sizes.blank?
        # e.g.: {"88x88"=>"88x88", "98x68"=>"98x65", "580x360"=>"540x360", "130x130"=>"130x130", "260x190"=>"260x173"}
        sizes = JSON.parse(medium.sizes)
        ii.large_size = sizes['580x360']
        ii.medium_size = sizes['260x190']
        ii.small_size = sizes['98x68']
      end
      ii.crop_x = medium.crop_x_pct
      ii.crop_y = medium.crop_y_pct
      ii.crop_w = medium.crop_w_pct
      ii.resource_pk = clean_values(medium.resource_pk)
      ii
    end

    def article_to_struct(node, article)
      web_article = Struct::WebArticle.new
      web_article.page_id = node.page_id
      add_db_id(web_article, article)
      web_article.owner = article.owner
      copy_fields(SAME_ARTICLE_ATTRIBUTES, article, web_article)
      add_resource_id(web_article)
      web_article.license_id = WebDb.license(article.license&.source_url, @process)
      web_article.language_id = WebDb.language(article.language, @process)
      web_article
    end

    def vernacular_to_struct(node, vernacular)
      web_vern = Struct::WebVernacular.new
      web_vern.page_id = node.page_id
      add_db_id(web_vern, vernacular)
      add_resource_id(web_vern)
      web_vern.language_id = WebDb.language(vernacular.language, @process)
      web_vern.is_preferred_by_resource = clean_values(vernacular.is_preferred || false)
      web_vern.string = clean_values(vernacular.verbatim)
      copy_fields(SAME_VERNACULAR_ATTRIBUTES, vernacular, web_vern)
      web_vern
    end

    private

    def copy_fields(fields, source, dest)
      fields.each do |field|
        val = source.attributes.key?(field) ? source[field] : source.send(field)
        dest[field] = clean_values(val)
      end
    end

    def clean_values(src)
      val = src.dup
      if val.respond_to?(:gsub!)
        val.gsub!("\t", '&nbsp;') # Sorry, no tabs allowed.
      end
      val = 1 if val.class == TrueClass
      val = 0 if val.class == FalseClass
      val
    end

    def fixed_medium_url(medium, type)
      url_method_name = "#{type}_url"
      default_url_method_name = "default_#{type}_url"

      if medium.base_url.nil? # The image has not been downloaded.
        "#{@root_url}/#{medium.send(default_url_method_name)}"
      else
        # It *has* been downloaded, but still lacks the root URL, so we add that:
        "#{@root_url}/#{medium.send(url_method_name)}"
      end
    end

    def add_resource_id(model)
      model.resource_id = @web_resource_id
    end

    def add_db_id(model, source)
      model.harv_db_id = source.id
    end
  end
end
