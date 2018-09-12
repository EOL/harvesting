module Store
  module ModelBuilder
    def destroy_for_fmt
      @format.model_fks.each do |klass, key|
        removed_by_harvest(klass, key,
          @models[klass.name.underscore.to_sym][key])
      end
    end

    def reset_row
      # We *could* skip this, but I prefer not to deal with missing keys: makes the code cleaner
      @models = { node: nil, scientific_name: nil, ancestors: nil, medium: nil, vernacular: nil, occurrence: nil,
                  trait: nil, identifiers: nil, location: nil, ref: nil }
    end

    def build_models
      build_licenses
      fix_parent_fks_used_for_accepted_fks
      @synonym = is_synonym?
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
      return if @licenses
      @licenses = {}
      License.select("id, source_url").each { |lic| @licenses[lic.source_url] = lic.id }
    end

    # NOTE: Some resources (esp. older ones) can overload the "parentNameUsageID" field when the taxonomic status is not
    # prefered. ...This indicates a synonym, and the "parentNameUsageID" should be treated as an "acceptedNameUsageID"
    # value instead (which the code uses as the "synonym_of" field on the scientific name hash).
    def fix_parent_fks_used_for_accepted_fks
      return unless @models[:node]
      return unless @models[:scientific_name].key?(:taxonomic_status_verbatim)
      return if @models[:scientific_name][:taxonomic_status_verbatim].blank?
      preferred = TaxonomicStatus.preferred?(@models[:scientific_name][:taxonomic_status_verbatim])
      return if @models[:node][:parent_resource_pk].blank? || preferred
      raise 'Synonym provided, but no scientific name available to assign it to!' if @models[:scientific_name].nil?
      @models[:scientific_name][:synonym_of] = @models[:node].delete(:parent_resource_pk)
    end

    def is_synonym?
      @models[:scientific_name] && @models[:scientific_name][:synonym_of]
    end

    def build_scientific_name
      @models[:scientific_name][:resource_id] = @resource.id
      @models[:scientific_name][:harvest_id] = @harvest.id
      @models[:scientific_name][:resource_pk] = @models[:node][:resource_pk] # Always the same, especially for synonyms.
      if @synonym
        syn_of = @models[:scientific_name].delete(:synonym_of)
        @models[:scientific_name][:node_resource_pk] = syn_of
        @models[:scientific_name][:is_preferred] = false
      else
        @models[:scientific_name][:node_resource_pk] = @models[:node][:resource_pk]
        @models[:scientific_name][:is_preferred] = true
      end
      @models[:scientific_name][:taxonomic_status] = @models[:scientific_name][:taxonomic_status_verbatim].blank? ?
        :preferred :
        parse_status(@models[:scientific_name][:taxonomic_status_verbatim])

      prepare_model_for_store(ScientificName, @models[:scientific_name])
    end

    def parse_status(status)
      begin
        TaxonomicStatus.parse(status)
      rescue Errors::UnmatchedTaxonomicStatus => e
        log_warning("New Taxonomic status: #{status}; treatings as unusable...") unless @bad_statuses.key?(status)
        @bad_statuses[status] = true
        return :unusable
      end
    end

    def build_node
      return if @synonym # Don't build a node for synonyms.
      @models[:node][:resource_id] ||= @resource.id
      @models[:node][:harvest_id] ||= @harvest.id
      unless @models[:node][:rank_verbatim].blank?
        # NOTE: #clean_rank creates a (normalized) STRING, not an ID. q.v.
        @models[:node][:rank] = clean_rank(@models[:node][:rank_verbatim])
      end
      build_references(:node, NodesReference)
      prepare_model_for_store(Node, @models[:node])
    end

    # TODO: an UPDATE of this type might be trickier to handle than I have here. e.g.: The only change on this row was
    # to set "Karninvora" to "Carnivora"; we do not unpublish "Karnivora" (rightly, because we don't know whether it's
    # actually used elsewhere), so it will still exist and still be published and will still have children that it
    # shouldn't. But, as mentioned, this is a difficult case to detect.
    def build_ancestors
      ancestry = []
      prev = nil
      Rank.sort(@models[:ancestors].keys).each do |rank|
        ancestor_pk = @models[:ancestors][rank]
        ancestry << ancestor_pk
        ancestry_joined = ancestry.join('->')
        # DUPES_OK sci_name = @models[:scientific_name][:verbatim]
        # NOTE: @nodes_by_ancestry is just a cache, to make sure we don't redefine things. The value is never used.
        if @nodes_by_ancestry.key?(ancestry_joined)
          # Do nothing. We used to want to avoid dupes, but now I think DUPES_OK as long as the IDs are different, and
          # validations would have already checked that.

          # DUPES_OK if @nodes_by_ancestry[ancestry_joined].include?(sci_name)
          # DUPES_OK   # TODO: catch errors at the harvesting level; we want to log and somehow stop the process, not exit.
          # DUPES_OK   raise "ILLEGAL DUPLICATE: #{ancestry_joined}->#{sci_name}"
          # DUPES_OK end
        else # New ancestry...
          model =
            if @diff == :new
              model = { harvest_id: @harvest.id, resource_id: @resource.id, rank_verbatim: rank,
                        parent_resource_pk: prev, resource_pk: ancestor_pk }
              prepare_model_for_store(Node, model)
              name = { resource_id: @resource.id, harvest_id: @harvest.id, node_resource_pk: ancestor_pk,
                       verbatim: ancestor_pk, taxonomic_status_verbatim: 'HARVEST ANCESTOR' }
              prepare_model_for_store(ScientificName, name)
            else
              # NOTE: This will happen less often, so I'm allowing DB call; if this becomes problematic, we can
              # (of course) cache these...
              Node.find_by_resource_pk(ancestor_pk)
            end
          # DUPES_OK @nodes_by_ancestry[ancestry_joined] ||= [] # Remember that we don't need to do this again.
          # DUPES_OK @nodes_by_ancestry[ancestry_joined] << sci_name
          @nodes_by_ancestry[ancestry_joined] = true
        end
        prev = ancestor_pk
      end
      @models[:node][:parent_resource_pk] = prev
    end

    def build_identifiers
      @models[:identifiers].each do |identifier|
        ider = {}
        ider[:node_resource_pk] = @models[:node][:resource_pk]
        ider[:identifier] = identifier
        ider[:resource_id] = @resource.id
        ider[:harvest_id] = @harvest.id
        prepare_model_for_store(Identifier, ider)
      end
    end

    def build_location
      @locations ||= {}
      loc_key = @models[:location].to_s
      location = if @locations.key?(loc_key)
        @locations[loc_key]
      else
        # NOTE: this is NOT delayed; it is instantly created (unless it exists). ...This is slow. :S ...the
        # alternative isn't much faster, though, since we'll have to do as many updates (of media). Sigh.
        Location.where(@models[:location]).first_or_create
      end
      # TODO: this can also be associated with other classes, I think. But, for now, only media are req'd:
      @models[:medium][:location_id] = location.id
    end

    def build_medium
      @models[:medium][:resource_pk] = fake_pk(:medium) unless @models[:medium][:resource_pk]
      raise 'MISSING TAXA IDENTIFIER (FK) FOR MEDIUM!' unless @models[:medium][:node_resource_pk]
      @models[:medium][:resource_id] = @resource.id
      @models[:medium][:harvest_id] = @harvest.id
      lic_url = @models[:medium].delete(:license_url)
      @models[:medium][:license_id] ||= find_or_build_license(lic_url)
      if @models[:medium][:is_article]
        @models[:article] = @models[:medium]
        build_article
      else
        build_true_medium
      end
    end

    def build_article
      @models[:article][:guid] = "EOL-article-#{@resource.id}-#{@models[:article][:node_resource_pk]}"
      build_references(:article, ArticlesReference)
      build_attributions(Article, @models[:article])
      truncate(:article, :name, 254)
      @models[:article][:body] = @models[:article].delete(:description)
      build_sections(@models[:article].delete(:section_value))
      # Articles have far less information than media:
      %i[subclass format is_article name_verbatim description_verbatim].each do |superfluous_field|
        @models[:article].delete(superfluous_field)
      end
      prepare_model_for_store(Article, @models[:article])
    end

    def build_true_medium
      @models[:medium][:guid] = "EOL-media-#{@resource.id}-#{@models[:medium][:node_resource_pk]}"
      @models[:medium][:subclass] ||= :image
      @models[:medium][:format] ||= :jpg
      build_references(:medium, MediaReference)
      build_attributions(Medium, @models[:medium])
      # TODO: generalize this. We'll likely want to truncate other fields...
      @models[:medium][:name_verbatim] ||= ''
      truncate(:medium, :name_verbatim, 254, warn: true)
      @models[:medium][:name] ||= @models[:medium][:name_verbatim]
      truncate(:medium, :name, 254)
      prepare_model_for_store(Medium, @models[:medium])
    end

    def truncate(model, field, length, options = {})
      if @models[model][field].size > length
        longer = length + 256
        # Max length on log line (the limit is bout 64_000, but that's tedious and doesn't give us much more info.)
        longer = 2000 if longer > 2000
        log_warning("title is too long for medium #{@models[model][:resource_pk]}; truncating to #{length} chars: "\
          "#{@models[model][field][0..longer]}...") if options[:warn]
        @models[model][field] = @models[model][field][0..length]
      end
    end

    def find_or_build_license(url)
      if url.blank?
        return @resource.default_license&.id || License.public_domain.id
      end
      return @licenses[url] if @licenses.key?(url)
      name =
        if url =~ /creativecommons\/licenses/
          "cc-" + url.split('/')[-2..-1].join(' ')
        else
          url.split('/').last.titleize
        end
      license = License.create(name: name, source_url: url, can_be_chosen_by_partners: false)
      @licenses[url] = license.id
    end

    def build_references(key, klass)
      unless @models[key][:ref_fks].blank?
        sep = "[#{@models[key].delete(:ref_sep) || '|;'}]"
        fks = @models[key].delete(:ref_fks)
        fks.split(/#{sep}\s*/).each do |ref_fk|
          prepare_model_for_store(klass, "#{key}_resource_fk": @models[key][:resource_pk],
                                         ref_resource_fk: ref_fk, harvest_id: @harvest.id)
        end
      end
    end

    # TODO: handle things if there's no "is_preferred" field. ...not sure if we should assume pref'd or not, though.
    def build_vernacular
      lang_code = @models[:vernacular][:language_code_verbatim] || 'en'
      lang = find_or_create_language(lang_code)
      @models[:vernacular][:resource_id] = @resource.id
      @models[:vernacular][:harvest_id] = @harvest.id
      @models[:vernacular][:language_id] = lang.id
      # TODO: there are some other normalizations and checks we should do here, I expect.
      prepare_model_for_store(Vernacular, @models[:vernacular])
    end

    def build_occurrence
      @models[:occurrence][:harvest_id] = @harvest.id
      @models[:occurrence][:resource_id] = @resource.id
      meta = @models[:occurrence].delete(:meta) || {}
      if @models[:occurrence][:sex]
        sex = @models[:occurrence].delete(:sex)
        @models[:occurrence][:sex_term_id] = find_or_create_term(sex, type: 'sex').try(:id)
      end
      if @models[:occurrence][:lifestage]
        lifestage = @models[:occurrence].delete(:lifestage)
        @models[:occurrence][:lifestage_term_id] = find_or_create_term(lifestage, type: 'lifestage').try(:id)
      end
      # TODO: there are some other normalizations and checks we should do here, # I expect.
      prepare_model_for_store(Occurrence, @models[:occurrence])
      meta.each do |key, value|
        datum = {}
        datum[:occurrence_resource_pk] = @models[:occurrence][:resource_pk]
        predicate_term = find_or_create_term(key, type: 'meta-predicate')
        datum[:predicate_term_id] = predicate_term.id
        datum = convert_meta_value(datum, value, predicate: predicate_term)
        datum[:resource_id] = @resource.id
        datum[:harvest_id] = @harvest.id
        datum.delete(:source) # TODO: we should allow (and show) this. :S
        prepare_model_for_store(OccurrenceMetadatum, datum)
      end
    end

    def build_trait
      parent = @models[:trait][:parent_pk]
      occurrence = @models[:trait][:occurrence_resource_pk]
      @models[:trait][:resource_id] = @resource.id
      @models[:trait][:harvest_id] = @harvest.id
      debugger if Rails.env.development? && @models[:trait][:predicate].match?(/contributor/) # Testing IUCN-SD...
      if @models[:trait][:of_taxon] && parent
        return log_warning("IGNORING a measurement of a taxon (#{@models[:trait][:resource_pk]}) WITH a "\
                           "parentMeasurementID #{parent}")
      end
      if !@models[:trait][:of_taxon] && parent.blank? && occurrence.blank?
        puts @models[:trait].inspect
        return log_warning("IGNORING a measurement NOT of a taxon (#{@models[:trait][:resource_pk]}) with NO parent "\
                           'and NO occurrence ID.')
      end
      @models[:trait][:resource_pk] ||= (@default_trait_resource_pk += 1)
      build_references(:trait, TraitsReference)
      @models[:trait][:of_taxon] = true unless @models[:trait].key?(:of_taxon)
      # Example of occurrence metadata: Leptonychotes weddellii from PanTHERia. Should have metadata of body mass of
      # 368000 grams on its basal metabolic rate of 113712 mL/hr O2.
      occ_meta = !@models[:trait][:of_taxon] && parent.blank?  # Convenience flag to denote occurrence metadata.
      predicate = @models[:trait].delete(:predicate)
      predicate_term = find_or_create_term(predicate, type: 'predicate')
      @models[:trait][:predicate_term_id] = predicate_term.id
      units = @models[:trait].delete(:units)
      units_term = find_or_create_term(units, type: 'units')
      @models[:trait][:units_term_id] = units_term.try(:id)

      @models[:trait] = convert_trait_value(@models[:trait], predicate: predicate_term)

      if @models[:trait][:statistical_method]
        stat_m = @models[:trait].delete(:statistical_method)
        @models[:trait][:statistical_method_term_id] = find_or_create_term(stat_m, type: 'statistical method').try(:id)
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
        datum = {}
        datum[:resource_id] = @resource.id
        datum[:harvest_id] = @harvest.id
        datum[:trait_resource_pk] = trait.resource_pk unless occ_meta
        predicate_term = find_or_create_term(key, type: 'meta-predicate')
        datum[:predicate_term_id] = predicate_term.id
        datum = convert_meta_value(datum, value, predicate: predicate_term)
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
      @models[:assoc][:resource_id] = @resource.id
      @models[:assoc][:harvest_id] = @harvest.id
      predicate = @models[:assoc].delete(:predicate)
      predicate_term = find_or_create_term(predicate, type: 'predicate')
      @models[:assoc][:predicate_term_id] = predicate_term.id
      meta = @models[:assoc].delete(:meta) || {}
      @models[:assoc][:resource_pk] ||= (@default_trait_resource_pk += 1)
      build_references(:assoc, AssocsReference)
      # NOTE: JH: "please do [ignore agents for data]. The Contributor column data is appearing in beta, so you’re putting
      # it somewhere, and that’s all that matters for mvp"
      # build_attributions(Assoc, @models[:assoc])
      assoc = prepare_model_for_store(Assoc, @models[:assoc])
      meta.each do |key, value|
        datum = {}
        predicate_term = find_or_create_term(key, type: 'meta-predicate')
        datum[:predicate_term_id] = predicate_term.id
        datum[:harvest_id] = @harvest.id
        datum[:resource_id] = @resource.id
        datum[:trait_resource_pk] = assoc.resource_pk
        datum = convert_meta_value(datum, value, predicate: predicate_term)
        prepare_model_for_store(MetaAssoc, datum)
      end
    end

    def build_ref
      @models[:reference][:resource_id] ||= @resource.id
      @models[:reference][:harvest_id] ||= @harvest.id
      # NOTE: sometimes all there is, is a URL or a DOI (or both), with an empty body.
      @models[:reference][:body] = @models[:reference][:parts].join(' ') if
        @models[:reference][:body].blank? && @models[:reference][:parts]
      @models[:reference].delete(:parts)
      prepare_model_for_store(Reference, @models[:reference])
    end

    def build_attribution
      @models[:attribution][:resource_id] ||= @resource.id
      @models[:attribution][:harvest_id] ||= @harvest.id
      # NOTE: the role *can* be nil. It's not required. ...but the publishing DB DOES require it, so we're setting a
      # default here of "contributor" per JH's suggestion. It's vague enough that it works.
      @models[:attribution][:role] = symbolize(@models[:attribution][:role]) || :contributor
      if (other_info = @models[:attribution].delete(:other_info))
        @models[:attribution][:other_info] = other_info.to_json
      end
      prepare_model_for_store(Attribution, @models[:attribution])
    end

    def build_attributions(klass, model)
      return if model[:attributions].blank?
      sep = "[#{model.delete(:attribution_sep) || '|;'}]"
      unless model[:attributions].blank?
        model[:attributions].split(/#{sep}\s*/).each do |fk|
          content_attribution = {
            content_type: klass.to_s,
            content_resource_fk: model[:resource_pk],
            attribution_resource_fk: fk,
            resource_id: @resource.id,
            harvest_id: @harvest.id
          }
          prepare_model_for_store(ContentAttribution, content_attribution)
        end
      end
      model.delete(:attributions)
    end

    def build_sections(values)
      return nil if values.blank?
      # Sorry, not making this separator configurable. :|
      values.split(/\s*[|;]\s*/).each do |value|
        sid = find_section(value)
        next if sid.nil?
        prepare_model_for_store(ArticlesSection,
                                article_pk: @models[:article][:resource_pk], section_id: sid, harvest_id: @harvest.id)
      end
    end

    def find_section(orig_value)
      return nil if orig_value.blank?
      value = orig_value.gsub(/\s+\Z/, '').gsub(/\A\s+/, '') # Strip space, of course.
      @section_values ||= {}
      return @section_values[value] if @section_values.key?(value)
      unless SectionValue.exists?(value: value)
        log_warning("Could not find a section value of '#{value}' for article #{@models[:article][:resource_pk]}")
        return @section_values[value] = nil
      end
      @section_values[value] = SectionValue.where(value: value).pluck(:section_id).first
    end

    def symbolize(str)
      return nil if str.blank?
      str.downcase.gsub(/\W+/, '_').underscore.gsub(/_+$/, '').gsub(/^_+/, '').gsub(/_+/, '_')
    end

    def convert_trait_value(instance, options = {})
      value = instance.delete(:value)
      if options[:predicate]&.is_verbatim_only?
        instance[:literal] = value
        return instance
      end
      if Term.uri?(value)
        object_term = find_or_create_term(value, type: 'value')
        instance[:object_term_id] = object_term.id
      end
      # NOTE we have to check both for units AND for a numeric value to see if it's "numeric"
      if instance[:units] || (!Float(value&.tr(',', '')).nil? rescue false) # rubocop:disable Style/RescueModifier
        units = instance.delete(:units)
        if Term.uri?(units)
          units_term = find_or_create_term(units, type: 'units')
          instance[:units_term_id] = units_term.id
        elsif !units.blank?
          log_warning("Found a non-URI unit of '#{units}'! ...Forced to ignore.")
        end
        # TODO: Ideally, we need to know whether the source file users commas or periods as a delimiter.
        instance[:measurement] = value&.tr(',', '')
        # NOTE: We are handling unit normalization at the publishing layer for now.
      else
        # TODO: really, we want a robust map of literal values to reasonable URIs, but that should be "filtered".
        instance[:literal] = value
      end
      instance
    end

    # Simpler:
    def convert_meta_value(datum, value, options = {})
      if options[:predicate]&.is_verbatim_only?
        datum[:literal] = value
        return datum
      end
      if Term.uri?(value)
        object_term = find_or_create_term(value, type: 'meta-value')
        datum[:object_term_id] = object_term.id
      else
        datum[:literal] = value
      end
      datum
    end

    def find_or_create_term(uri, options = {})
      return nil if uri.blank?
      # TODO: again, this is slow to do one-at-a-time. We should get a full list
      # and query for all of them:
      term = @terms[uri] || Term.where(uri: uri).first
      if term.nil?
        # Quick and dirty. A Human will have to do better later:
        name = uri.gsub(%r{^.*/}, '').gsub(/[^A-Za-z0-9]+/, ' ')
        term = Term.create(
          uri: uri, name: name, definition: I18n.t('terms.auto_created'),
          comment: "Auto-added during harvest ##{@harvest.id}. A human needs to edit this.",
          attribution: @resource.name, is_hidden_from_overview: true,
          is_hidden_from_glossary: true
        )
        # TODO: This isn't necessarily a problem with the measurements file; it could be the occurrences. :S
        log_warning("Created #{options[:type] || '(unspecified type of)'} term for #{uri}!")
      end
      term
    end

    def find_or_create_language(lang_code)
      @languages_by_code ||= {}
      @languages_by_group ||= {}
      if @languages_by_code.key?(lang_code)
        @languages_by_code[lang_code]
      elsif @languages_by_group.key?(lang_code)
        @languages_by_group[lang_code]
      elsif Language.exists?(code: lang_code)
        lang = Language.where(code: lang_code).first
        @languages_by_code[lang_code] = lang
        lang
      elsif Language.exists?(group_code: lang_code)
        lang = Language.where(group_code: lang_code).first
        @languages_by_group[lang_code] = lang
        lang
      else
        attrs =
          if (iso = ISO_639.find(lang_code))
            { code: iso.alpha3, group_code: iso.alpha2 }
          else
            { code: lang_code, group_code: lang_code }
          end
        # NOTE: languages don't have "name" fields; that's handled by I18n based on the code.
        lang = Language.create!(attrs)
        @languages_by_code[lang_code] = lang
        lang
      end
    end

    def clean_rank(verbatim)
      @ranks ||= {}
      return @ranks[verbatim] if @ranks.key?(verbatim)
      @ranks[verbatim] = Rank.clean(verbatim)
    end

    # TODO: extract to Store::Storage
    def prepare_model_for_store(klass, model)
      if @diff == :changed
        key = @format.model_fks[klass]
        removed_by_harvest(klass, key, model[key])
      end
      @new[klass] ||= []
      new_model = klass.send(:new, model)
      @new[klass] << new_model
      new_model
    end

    # TODO: extract to Store::Storage
    def removed_by_harvest(klass, key, pk)
      @old[klass] ||= {}
      @old[klass][key] ||= []
      @old[klass][key] << pk
    end

    def fake_pk(type)
      @fake_pks ||= {}
      @fake_pks[type] ||= 0
      @fake_pks[type] += 1
    end
  end
end
