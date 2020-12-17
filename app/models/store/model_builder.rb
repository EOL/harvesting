module Store
  module ModelBuilder
    def destroy_for_fmt
      @format.model_fks.each do |klass, key|
        removed_by_harvest(klass, key, @models[klass.name.underscore.to_sym][key])
      end
    end

    def reset_row
      # We *could* skip this, but I prefer not to deal with missing keys: makes the code cleaner
      @models = { node: nil, scientific_name: nil, ancestors: nil, medium: nil, vernacular: nil, occurrence: nil,
                  trait: nil, identifiers: nil, location: nil, ref: nil, debug: false }
    end

    def build_models
      build_licenses
      fix_parent_fks_used_for_accepted_fks
      @synonym = synonym?
      @process.warn(@models[:log].join('; ')) if @models[:log]
      build_scientific_name if @models[:scientific_name]
      build_ancestors if @models[:ancestors]
      build_identifiers if @models[:identifiers]
      build_node if @models[:node]
      build_location if @models[:location]
      build_medium if @models[:medium]
      build_vernacular if @models[:vernacular] # TODO: this one is not very robust
      build_occurrence if @models[:occurrence]
      build_trait if @models[:trait]
      build_assoc if @models[:assoc]
      build_attribution if @models[:attribution]
      build_ref if @models[:reference]
      # TODO: still need to build article, js_map (?), link, map, sound, video
    end

    def build_licenses
      @process.debug('#build_licenses') if @models[:debug]
      return if @licenses

      @licenses = {}
      License.select('id, source_url').each { |lic| @licenses[lic.source_url] = lic.id }
    end

    # NOTE: Some resources (esp. older ones) can overload the "parentNameUsageID" field when the taxonomic status is not
    # prefered. ...This indicates a synonym, and the "parentNameUsageID" should be treated as an "acceptedNameUsageID"
    # value instead (which the code uses as the "synonym_of" field on the scientific name hash).
    def fix_parent_fks_used_for_accepted_fks
      @process.debug('#fix_parent_fks_used_for_accepted_fks') if @models[:debug]
      return unless @models[:node]
      return unless @models[:scientific_name].key?(:taxonomic_status_verbatim)
      return if @models[:scientific_name][:taxonomic_status_verbatim].blank?

      preferred = TaxonomicStatus.preferred?(@models[:scientific_name][:taxonomic_status_verbatim])
      return if @models[:node][:parent_resource_pk].blank? || preferred
      raise 'Synonym provided, but no scientific name available to assign it to!' if @models[:scientific_name].nil?

      @models[:scientific_name][:synonym_of] = @models[:node].delete(:parent_resource_pk)
    end

    # Opposite of is_preferred? ...but I think this is clearer...
    def synonym?
      @process.debug('#synonym?') if @models[:debug]
      @models[:scientific_name] && @models[:scientific_name][:synonym_of]
    end

    def build_scientific_name
      @process.debug('#build_scientific_name') if @models[:debug]
      @models[:scientific_name][:resource_id] = @resource.id
      @models[:scientific_name][:harvest_id] = @harvest.id
      @models[:scientific_name][:resource_pk] = @models[:node][:resource_pk] # Always the same, especially for synonyms.
      if @synonym
        syn_of = @models[:scientific_name].delete(:synonym_of)
        @models[:scientific_name][:node_resource_pk] = syn_of
        @models[:scientific_name][:is_preferred] = false
        #  KS: "Generally, records of non-preferred names don't have a parentNameUsageID, but sometimes they do. In
        #  records that have both an acceptedNameUsageID and a parentNameUsageID, the parentNameUsageID should be
        #  ignored"
        if @models[:node]
          @models[:node][:parent_resource_pk] = nil
          @process.debug('ignoring parentNameUsageID because there is an acceptedNameUsageID') if @models[:debug]
        end
      else
        @models[:scientific_name][:node_resource_pk] = @models[:node][:resource_pk]
        @models[:scientific_name][:is_preferred] = true
      end
      @models[:scientific_name][:taxonomic_status] =
        if @models[:scientific_name][:taxonomic_status_verbatim].blank?
          @process.debug('taxonomic_status_verbatim blank, setting as preferred') if @models[:debug]
          :preferred
        else
          status = parse_status(@models[:scientific_name][:taxonomic_status_verbatim])
          @process.debug("taxonomic_status_verbatim parsed as taxonomic status #{status}") if @models[:debug]
          status
        end

      prepare_model_for_store(ScientificName, @models[:scientific_name])
    end

    def parse_status(status)
      @process.debug('#parse_status') if @models[:debug]
      begin
        TaxonomicStatus.parse(status)
      rescue Errors::UnmatchedTaxonomicStatus => e
        @process.warn("New Taxonomic status: #{status}; treatings as unusable...") unless @bad_statuses.key?(status)
        @bad_statuses[status] = true
        return :unusable
      end
    end

    def build_node
      @process.debug('#build_node') if @models[:debug]
      return if @synonym # Don't build a node for synonyms.

      @process.debug('Not a synonym, proceeding.') if @models[:debug]
      @models[:node][:resource_id] ||= @resource.id
      @models[:node][:harvest_id] ||= @harvest.id
      unless @models[:node][:rank_verbatim].blank?
        # NOTE: #clean_rank creates a (normalized) STRING, not an ID. q.v.
        @models[:node][:rank] = clean_rank(@models[:node][:rank_verbatim])
        @process.debug("rank_verbatim provided, set rank to #{@models[:node][:rank]}") if @models[:debug]
      end
      build_references(:node, NodesReference)
      prepare_model_for_store(Node, @models[:node])
    end

    # TODO: an UPDATE of this type might be trickier to handle than I have here. e.g.: The only change on this row was
    # to set "Karninvora" to "Carnivora"; we do not unpublish "Karnivora" (rightly, because we don't know whether it's
    # actually used elsewhere), so it will still exist and still be published and will still have children that it
    # shouldn't. But, as mentioned, this is a difficult case to detect.
    def build_ancestors
      @process.debug('#build_ancestors') if @models[:debug]
      ancestry = []
      prev = nil
      Rank.sort(@models[:ancestors].keys).each do |rank|
        @process.debug("Handling rank #{rank}") if @models[:debug]
        ancestor_pk = @models[:ancestors][rank]
        ancestry << ancestor_pk
        ancestry_joined = ancestry.join('->')
        # NOTE: @nodes_by_ancestry is just a cache, to make sure we don't redefine things. The value is never used.
        if @nodes_by_ancestry.key?(ancestry_joined)
          # Do nothing. We used to want to avoid dupes, but now I think it's okay as long as the IDs are different, and
          # validations would have already checked that.
          @process.debug('ignoring duplicate node in ancestry') if @models[:debug]
        else # New ancestry...
          if @diff == :new
            @process.debug('new row, preparing node and name') if @models[:debug]
            model = { harvest_id: @harvest.id, resource_id: @resource.id, rank_verbatim: rank,
                      parent_resource_pk: prev, resource_pk: ancestor_pk, canonical: ancestor_pk }
            prepare_model_for_store(Node, model)
            name = { resource_id: @resource.id, harvest_id: @harvest.id, node_resource_pk: ancestor_pk,
                     verbatim: ancestor_pk, taxonomic_status_verbatim: 'HARVEST ANCESTOR', is_preferred: true }
            prepare_model_for_store(ScientificName, name)
          else
            @process.debug('old row, skipping') if @models[:debug]
            # Node.find_by_resource_pk(ancestor_pk)
          end
          @nodes_by_ancestry[ancestry_joined] = true
        end
        prev = ancestor_pk
      end
      @models[:node][:parent_resource_pk] = prev
    end

    def build_identifiers
      @process.debug('#build_identifiers') if @models[:debug]
      @models[:identifiers].each do |identifier|
        @process.debug("Building identifier for {#{identifier}}") if @models[:debug]
        ider = {}
        ider[:node_resource_pk] = @models[:node][:resource_pk]
        ider[:identifier] = identifier
        ider[:resource_id] = @resource.id
        ider[:harvest_id] = @harvest.id
        prepare_model_for_store(Identifier, ider)
      end
    end

    def build_location
      @process.debug('#build_location') if @models[:debug]
      @locations ||= {}
      loc_key = @models[:location].to_s
      location =
        if @locations.key?(loc_key)
          @locations[loc_key]
        else
          @process.debug('location unknown; creating new (slow)') if @models[:debug]
          # NOTE: this is NOT delayed; it is instantly created (unless it exists). ...This is slow. :S ...the
          # alternative isn't much faster, though, since we'll have to do as many updates (of media). Sigh.
          Location.where(@models[:location]).first_or_create
        end
      # TODO: this can also be associated with other classes, I think. But, for now, only media are req'd:
      @models[:medium][:location_id] = location.id
    end

    def build_medium
      @process.debug('#build_medium') if @models[:debug]
      unless medium_types_valid?
        @process.warn("skipping invalid medium with resource_pk #{@models[:medium][:resource_pk]}, subclass "\
          "#{@models[:medium][:subclass]} (from #{@models[:medium][:original_type]}), format "\
          "#{@models[:medium][:format]} (from #{@models[:medium][:original_format]})")
        return
      end

      delete_extra_medium_fields

      @models[:medium][:resource_pk] = fake_pk(:medium) unless @models[:medium][:resource_pk]
      raise 'MISSING TAXA IDENTIFIER (FK) FOR MEDIUM!' unless @models[:medium][:node_resource_pk]

      @models[:medium][:resource_id] = @resource.id
      @models[:medium][:harvest_id] = @harvest.id
      lic_url = @models[:medium].delete(:license_url)
      @models[:medium][:license_id] ||= find_or_build_license(lic_url)
      build_bib_cit(@models[:medium].delete(:bib_cit), @models[:medium][:resource_pk])
      lang_code = @models[:medium][:language_code_verbatim] || 'en'
      lang = find_or_create_language(lang_code)
      @models[:medium][:language_id] = lang.id
      if @models[:medium][:is_article]
        @process.debug('...is Article') if @models[:debug]
        @models[:article] = @models[:medium]
        build_article
      else
        @process.debug('...is normal Medium') if @models[:debug]
        build_true_medium
      end
    end

    def delete_extra_medium_fields
      @process.debug('#delete_extra_medium_fields') if @models[:debug]
      @models[:medium].delete(:original_type)
      @models[:medium].delete(:original_format)
    end

    def medium_types_valid?
      @process.debug('#medium_types_valid') if @models[:debug]
      @models[:medium][:subclass].present? &&
        (@models[:medium][:is_article] || @models[:medium][:format].present?)
    end

    def build_article
      @process.debug('#build_article') if @models[:debug]
      @models[:article][:guid] = "EOL-article-#{@resource.id}-#{@models[:article][:resource_pk]}"
      truncate(:article, :name, 254)
      @models[:article][:body] = @models[:article].delete(:description)
      # TODO: we should check if the owner is blank, and if it is, check that the license allows it. If not, ignore the
      # entire record.

      # Commenting this out for now since we're having trouble with bogus owners.
      # if @models[:article][:owner].blank?
      #   @models[:article][:owner] =
      #     if @models[:article][:attributions].blank?
      #       @resource.name
      #     else
      #       sep = "[#{@models[:article][:attribution_sep] || '|;'}]"
      #       @models[:article][:attributions].split(/#{sep}\s*/).join('; ')
      #     end
      # end
      build_references(:article, ArticlesReference)
      build_attributions(Article, @models[:article])
      build_sections(@models[:article].delete(:section_value))
      if @models[:article][:source_url].blank?
        @process.debug('article source URL blank, using source page') if @models[:debug]
        @models[:article][:source_url] = @models[:article].delete(:source_page_url)
      elsif !@models[:article][:source_page_url].blank?
        raise "Attempt to specify both source_url and source_page_url on Article #{@models[:article][:resource_pk]}"
      end
      # Articles have far less information than media:
      %i[subclass format is_article name_verbatim description_verbatim source_page_url].each do |superfluous_field|
        @process.debug("Skipping superfluous #{superfluous_field}") if @models[:debug]
        @models[:article].delete(superfluous_field)
      end
      prepare_model_for_store(Article, @models[:article])
    end

    def build_true_medium
      @process.debug('#build_true_medium') if @models[:debug]
      @models[:medium][:guid] = "EOL-media-#{@resource.id}-#{@models[:medium][:resource_pk]}"
      build_references(:medium, MediaReference)
      build_attributions(Medium, @models[:medium])
      # TODO: generalize this. We'll likely want to truncate other fields...
      @models[:medium][:name_verbatim] ||= ''
      truncate(:medium, :name_verbatim, 254, warn: true)
      @models[:medium][:name] ||= @models[:medium][:name_verbatim]
      truncate(:medium, :name, 254)
      @models[:medium].delete(:section_value) # TODO: someday we probably want to keep this. Not today.
      prepare_model_for_store(Medium, @models[:medium])
    end

    def truncate(model, field, length, options = {})
      @process.debug('#truncate') if @models[:debug]
      return unless @models[model][field]

      @process.debug('not blank, continuing') if @models[:debug]
      return unless @models[model][field].size > length

      @process.debug("too long (#{@models[model][field].size}>#{length}), truncating") if @models[:debug]
      longer = length + 256
      # Max length on log line (the limit is bout 64_000, but that's tedious and doesn't give us much more info.)
      longer = 2000 if longer > 2000
      if options[:warn] || @models[:debug]
        @process.warn("title is too long for medium #{@models[model][:resource_pk]}; truncating to #{length} chars: "\
          "#{@models[model][field][0..longer]}...")
      end
      @models[model][field] = @models[model][field][0..length]
    end

    def find_or_build_license(url)
      @process.debug('#find_or_build_license') if @models[:debug]
      if url.blank?
        @process.debug('license URI is blank, using default') if @models[:debug]
        return @resource.default_license&.id || License.public_domain.id
      end
      return @licenses[url] if @licenses.key?(url)

      @process.debug('license not known, parsing.') if @models[:debug]
      name =
        if url =~ %r{creativecommons\.org\/licenses}
          @process.debug('license is CC, parsing as such') if @models[:debug]
          'cc-' + url.split('/')[-2..-1].join(' ')
        else
          @process.debug('using last term in license as the name') if @models[:debug]
          url.split('/').last.titleize
        end
      license = License.create(name: name, source_url: url, can_be_chosen_by_partners: false)
      @licenses[url] = license.id
    end

    def build_references(key, klass)
      @process.debug('#build_references') if @models[:debug]
      return if @models[key][:ref_fks].blank?

      @process.debug('reference FKs exist, continuing') if @models[:debug]
      sep = "[#{@models[key].delete(:ref_sep) || '|;'}]"
      fks = @models[key].delete(:ref_fks)
      fks.split(/#{sep}\s*/).each do |ref_fk|
        @process.debug("found ref FK {#{ref_fk}}") if @models[:debug]
        prepare_model_for_store(klass, "#{key}_resource_fk": @models[key][:resource_pk],
                                       ref_resource_fk: ref_fk, harvest_id: @harvest.id)
      end
    end

    # TODO: handle things if there's no "is_preferred" field. ...not sure if we should assume pref'd or not, though.
    def build_vernacular
      @process.debug('#build_vernacular') if @models[:debug]
      @models[:vernacular][:resource_id] = @resource.id
      @models[:vernacular][:harvest_id] = @harvest.id
      lang_code = @models[:vernacular][:language_code_verbatim] || 'en'
      lang = find_or_create_language(lang_code)
      @models[:vernacular][:language_id] = lang.id
      # TODO: there are some other normalizations and checks we should do here, I expect.
      prepare_model_for_store(Vernacular, @models[:vernacular])
    end

    def build_occurrence
      @process.debug('#build_occurrence') if @models[:debug]
      @models[:occurrence][:harvest_id] = @harvest.id
      @models[:occurrence][:resource_id] = @resource.id
      meta = @models[:occurrence].delete(:meta) || {}
      if @models[:occurrence][:sex]
        @process.debug('sex exists, treating as Term') if @models[:debug]
        sex = @models[:occurrence].delete(:sex)
        @models[:occurrence][:sex_term_uri] = fail_on_bad_uri(sex)
      end
      if @models[:occurrence][:lifestage]
        @process.debug('lifestage exists, treating as Term') if @models[:debug]
        lifestage = @models[:occurrence].delete(:lifestage)
        @models[:occurrence][:lifestage_term_uri] = fail_on_bad_uri(lifestage)
      end
      # TODO: there are some other normalizations and checks we should do here, # I expect.
      prepare_model_for_store(Occurrence, @models[:occurrence])
      meta.each do |key, value|
        @process.debug("setting meta #{key} to {#{value}}") if @models[:debug]
        datum = {}
        datum[:occurrence_resource_pk] = @models[:occurrence][:resource_pk]
        datum[:predicate_term_uri] = fail_on_bad_uri(key)
        datum = convert_meta_value(datum, value)
        datum[:resource_id] = @resource.id
        datum[:harvest_id] = @harvest.id
        datum.delete(:source) # TODO: we should allow (and show) this. :S
        prepare_model_for_store(OccurrenceMetadatum, datum)
      end
    end

    def build_trait
      @process.debug('#build_trait') if @models[:debug]
      parent = @models[:trait][:parent_pk] || @models[:trait][:parent_eol_pk]
      occurrence = @models[:trait][:occurrence_resource_pk]
      dup_model = @models[:trait].dup # TEMP:
      @models[:trait][:resource_id] = @resource.id
      @models[:trait][:harvest_id] = @harvest.id
      if @models[:trait][:of_taxon] && parent
        return @process.warn("IGNORING a measurement of a taxon (#{@models[:trait][:resource_pk]}) WITH a "\
                           "parentMeasurementID or parentEolPk #{parent}")
      end
      if !@models[:trait][:of_taxon] && parent.blank? && occurrence.blank?
        puts @models[:trait].inspect
        return @process.warn("IGNORING a measurement NOT of a taxon (#{@models[:trait][:resource_pk]}) with NO parent "\
                           'and NO occurrence ID.')
      end
      @models[:trait][:resource_pk] ||= (@default_trait_resource_pk += 1)
      build_references(:trait, TraitsReference)
      unless @models[:trait].key?(:of_taxon)
        @process.debug('trait is of_taxon') if @models[:debug]
        @models[:trait][:of_taxon] = true
      end
      # Example of occurrence metadata: Leptonychotes weddellii from PanTHERia. Should have metadata of body mass of
      # 368000 grams on its basal metabolic rate of 113712 mL/hr O2.
      occ_meta = !@models[:trait][:of_taxon] && parent.blank?  # Convenience flag to denote occurrence metadata.
      predicate = @models[:trait].delete(:predicate)
      puts "PREDICATE: #{predicate}"
      @models[:trait][:predicate_term_uri] = fail_on_bad_uri(predicate)
      puts "PRED URI: #{@models[:trait][:predicate_term_uri]}"
      units = @models[:trait].delete(:units)
      @models[:trait][:units_term_uri] = fail_on_bad_uri(units)

      # TEMP:
      begin
        @models[:trait] = convert_trait_value(@models[:trait], predicate: @models[:trait][:predicate_term_uri])
      rescue => e
        puts "Failed to convert value for #{@models[:trait][:predicate_term_uri]}"
        pp dup_model
        raise e
      end

      if @models[:trait][:statistical_method]
        @process.debug('statistical method exists, setting to Term') if @models[:debug]
        stat_m = @models[:trait].delete(:statistical_method)
        @models[:trait][:statistical_method_term_uri] = fail_on_bad_uri(stat_m)
      end
      meta = @models[:trait].delete(:meta) || {}
      klass = Trait
      klass = OccurrenceMetadatum if occ_meta
      @models[:trait].delete(:of_taxon) if occ_meta
      @models[:trait].delete(:source) if occ_meta # TODO: we should allow (and show) this. :S
      # NOTE: JH: "please do [ignore agents for data]. The Contributor column data is appearing in beta, so you’re putting
      # it somewhere, and that’s all that matters for mvp"
      # build_attributions(Trait, @models[:trait])
      trait = prepare_model_for_store(klass, @models[:trait])
      meta.each do |key, value|
        @process.debug("setting meta #{key} to #{value}") if @models[:debug]
        datum = {}
        datum[:resource_id] = @resource.id
        datum[:harvest_id] = @harvest.id
        datum[:trait_resource_pk] = trait.resource_pk unless occ_meta
        datum[:predicate_term_uri] = fail_on_bad_uri(key)
        datum = convert_meta_value(datum, value)
        klass = MetaTrait
        if !@models[:trait][:of_taxon] && parent.blank?
          klass = OccurrenceMetadatum
          datum[:resource_pk] = "meta_#{@models[:trait][:resource_pk]}"
          datum[:occurrence_resource_pk] = @models[:trait][:occurrence_resource_pk]
        end
        prepare_model_for_store(klass, datum)
      end
    end

    def build_assoc
      @process.debug('#build_assoc') if @models[:debug]
      @models[:assoc][:resource_id] = @resource.id
      @models[:assoc][:harvest_id] = @harvest.id
      predicate = @models[:assoc].delete(:predicate)
      @models[:assoc][:predicate_term_uri] = fail_on_bad_uri(predicate)
      meta = @models[:assoc].delete(:meta) || {}
      @models[:assoc][:resource_pk] ||= (@default_trait_resource_pk += 1)
      build_references(:assoc, AssocsReference)
      # NOTE: JH: "please do [ignore agents for data]. The Contributor column data is appearing in beta, so you’re putting
      # it somewhere, and that’s all that matters for mvp"
      # build_attributions(Assoc, @models[:assoc])
      assoc = prepare_model_for_store(Assoc, @models[:assoc])
      meta.each do |key, value|
        @process.debug("setting meta #{key} to {#{value}}") if @models[:debug]
        datum = {}
        datum[:predicate_term_uri] = fail_on_bad_uri(key)
        datum[:harvest_id] = @harvest.id
        datum[:resource_id] = @resource.id
        datum[:assoc_resource_fk] = assoc.resource_pk
        datum = convert_meta_value(datum, value)
        prepare_model_for_store(MetaAssoc, datum)
      end
    end

    def build_ref
      @process.debug('#build_ref') if @models[:debug]
      @models[:reference][:resource_id] ||= @resource.id
      @models[:reference][:harvest_id] ||= @harvest.id
      # NOTE: sometimes all there is, is a URL or a DOI (or both), with an empty body.
      if @models[:reference][:body].blank? && @models[:reference][:parts]
        @process.debug('reference has parts, joining for body') if @models[:debug]
        @models[:reference][:body] = @models[:reference][:parts].join(' ')
      end
      @models[:reference].delete(:parts)
      prepare_model_for_store(Reference, @models[:reference])
    end

    def build_attribution
      @process.debug('#build_attribution') if @models[:debug]
      @models[:attribution][:resource_id] ||= @resource.id
      @models[:attribution][:harvest_id] ||= @harvest.id
      # NOTE: the role *can* be nil. It's not required. ...but the publishing DB DOES require it, so we're setting a
      # default here of "contributor" per JH's suggestion. It's vague enough that it works.
      @models[:attribution][:role] = symbolize(@models[:attribution][:role]) || :contributor
      if (other_info = @models[:attribution].delete(:other_info))
        @process.debug('other_info set in attribution, changing to JSON') if @models[:debug]
        @models[:attribution][:other_info] = other_info.to_json
      end
      prepare_model_for_store(Attribution, @models[:attribution])
    end

    def build_attributions(klass, model)
      @process.debug('#build_attributions') if @models[:debug]
      return if model[:attributions].blank?

      @process.debug('attributions not blank, continuing') if @models[:debug]
      sep = "[#{model.delete(:attribution_sep) || '|;'}]"
      model[:attributions].split(/#{sep}\s*/).each do |fk|
        @process.debug("found attribution {#{fk}}") if @models[:debug]
        content_attribution = {
          content_type: klass.to_s,
          content_resource_fk: model[:resource_pk],
          attribution_resource_fk: fk,
          resource_id: @resource.id,
          harvest_id: @harvest.id
        }
        prepare_model_for_store(ContentAttribution, content_attribution)
      end
      model.delete(:attributions)
    end

    def build_bib_cit(value, resource_pk)
      @process.debug('#build_bib_cit') if @models[:debug]
      return nil if value.blank?

      @process.debug('value not blank, continuing') if @models[:debug]
      # TODO: we should do some scrubbing of that body content:
      prepare_model_for_store(BibliographicCitation, body: value, resource_pk: resource_pk, resource_id: @resource.id,
                                                     harvest_id: @harvest.id)
    end

    def build_sections(values)
      @process.debug('#build_sections') if @models[:debug]
      return nil if values.blank?

      @process.debug('values not blank, continuing') if @models[:debug]
      # Sorry, not making this separator configurable. :|
      values.split(/\s*[|;]\s*/).each do |value|
        @process.debug("found value {#{value}}") if @models[:debug]
        sid = find_section(value)
        if sid.nil?
          @process.debug('skipping blank section') if @models[:debug]
          next
        end
        prepare_model_for_store(ArticlesSection,
                                article_pk: @models[:article][:resource_pk], section_id: sid, harvest_id: @harvest.id)
      end
    end

    def find_section(orig_value)
      @process.debug('#find_section') if @models[:debug]
      return nil if orig_value.blank?

      @process.debug("original value not blank ({#{orig_value}}), continuing...")
      value = orig_value.gsub(/\s+\Z/, '').gsub(/\A\s+/, '') # Strip space, of course.
      @section_values ||= {}
      return @section_values[value] if @section_values.key?(value)

      @process.debug("Section value {#{@section_values[value]}} not known, continuing...") if @models[:debug]
      unless SectionValue.exists?(value: value)
        @process.warn("Could not find a section value of '#{value}' for article #{@models[:article][:resource_pk]}")
        return @section_values[value] = nil
      end
      @section_values[value] = SectionValue.where(value: value).pluck(:section_id).first
    end

    def symbolize(str)
      @process.debug('#symbolize') if @models[:debug]
      return nil if str.blank?

      @process.debug('string not blank, continuing') if @models[:debug]
      str.downcase.gsub(/\W+/, '_').underscore.gsub(/_+$/, '').gsub(/^_+/, '').gsub(/_+/, '_')
    end

    def convert_trait_value(instance, options = {})
      @process.debug('#convert_trait_value') if @models[:debug]
      value = instance.delete(:value)
      if options[:predicate] && EolTerms.by_uri(options[:predicate])['is_text_only']
        @process.debug('predicate flagged as text-only, setting literal only') if @models[:debug]
        instance[:literal] = value
        return instance
      end
      if Term.uri?(value)
        @process.debug('value recognized as URI, treating as term') if @models[:debug]
        instance[:object_term_uri] = fail_on_bad_uri(value)
      end
      # NOTE we have to check both for units AND for a numeric value to see if it's "numeric"
      if instance[:units] || (!Float(value&.tr(',', '')).nil? rescue false) # rubocop:disable Style/RescueModifier
        @process.debug('instance has units') if @models[:debug]
        units = instance.delete(:units)
        if Term.uri?(units)
          @process.debug('units looks like a URI, treating as term') if @models[:debug]
          instance[:units_term_uri] = fail_on_bad_uri(units)
        elsif !units.blank?
          raise("Found a non-URI unit of '#{units}'! ...Forced to ignore.")

        end
        # TODO: Ideally, we need to know whether the source file users commas or periods as a delimiter.
        instance[:measurement] = value&.tr(',', '')
        # NOTE: We are handling unit normalization at the publishing layer for now.
      else
        @process.debug('instance does NOT have units, setting literal') if @models[:debug]
        # TODO: really, we want a robust map of literal values to reasonable URIs, but that should be "filtered".
        instance[:literal] = value
      end
      instance
    end

    # Simpler:
    def convert_meta_value(datum, value)
      @process.debug('#convert_meta_value') if @models[:debug]
      if datum[:predicate_term_uri] && EolTerms.by_uri(datum[:predicate_term_uri])['is_text_only']
        datum[:literal] = value
        @process.debug('predicate URI flagged as text-only, setting literal only') if @models[:debug]
        return datum
      end
      if Term.uri?(value)
        @process.debug('treating value as a URI') if @models[:debug]
        datum[:object_term_uri] = fail_on_bad_uri(value)
      else
        datum[:literal] = value
      end
      datum
    end

    def fail_on_bad_uri(uri)
      @process.debug('#fail_on_bad_uri') if @models[:debug]
      return nil if uri.blank?

      @process.debug('URI is NOT blank, continue...') if @models[:debug]
      raise "Missing Term for URI `#{uri}`, must be added!" unless EolTerms.includes_uri?(uri.downcase)

      uri.downcase # This is perhaps SLIGHTLY dangerous, but: URIs are SUPPOSED to be case-insensitive!
    end

    def find_or_create_language(lang_code)
      @process.debug('#find_or_create_language') if @models[:debug]
      @languages_by_code ||= {}
      @languages_by_group ||= {}
      if @languages_by_code.key?(lang_code)
        @process.debug('language known') if @models[:debug]
        @languages_by_code[lang_code]
      elsif @languages_by_group.key?(lang_code)
        @process.debug('language group known') if @models[:debug]
        @languages_by_group[lang_code]
      elsif Language.exists?(code: lang_code)
        @process.debug('language in database') if @models[:debug]
        lang = Language.where(code: lang_code).first
        @languages_by_code[lang_code] = lang
        lang
      elsif Language.exists?(group_code: lang_code)
        @process.debug('language group in database') if @models[:debug]
        lang = Language.where(group_code: lang_code).first
        @languages_by_group[lang_code] = lang
        lang
      else
        @process.debug("creating new language for #{lang_code}") if @models[:debug]
        attrs =
          if (iso = ISO_639.find(lang_code))
            @process.debug('code found in ISO_629 gem') if @models[:debug]
            { code: iso.alpha3, group_code: iso.alpha2 }
          else
            @process.debug('code NOT found in ISO_629 gem, building custom') if @models[:debug]
            { code: lang_code, group_code: lang_code }
          end
        # NOTE: languages don't have "name" fields; that's handled by I18n based on the code.
        lang = Language.create!(attrs)
        @languages_by_code[lang_code] = lang
        lang
      end
    end

    def clean_rank(verbatim)
      @process.debug('#clean_rank') if @models[:debug]
      @ranks ||= {}
      return @ranks[verbatim] if @ranks.key?(verbatim)

      @ranks[verbatim] = Rank.clean(verbatim)
    end

    # TODO: extract to Store::Storage
    def prepare_model_for_store(klass, model)
      @process.debug('#prepare_model_for_store') if @models[:debug]
      if @diff == :changed
        key = @format.model_fks[klass]
        removed_by_harvest(klass, key, model[key])
      end
      @new[klass] ||= []
      new_model = klass.send(:new, model)
      @new[klass] << new_model
      new_model.prepare_for_store(@process) if new_model.respond_to?(:prepare_for_store)
      new_model
    end

    # TODO: extract to Store::Storage
    def removed_by_harvest(klass, key, pk)
      @process.debug('#removed_by_harvest') if @models[:debug]
      @old[klass] ||= {}
      @old[klass][key] ||= []
      @old[klass][key] << pk
    end

    def fake_pk(type)
      @process.debug('#fake_pk') if @models[:debug]
      @fake_pks ||= {}
      @fake_pks[type] ||= 0
      @fake_pks[type] += 1
    end
  end
end
