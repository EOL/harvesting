module Store
  module ModelBuilder
    def destroy_for_fmt
      @format.model_fks.each do |klass, key|
        removed_by_harvest(klass, key,
          @models[klass.name.underscore.to_sym][key])
      end
    end

    def build_models
      build_scientific_name if @models[:scientific_name]
      build_ancestors if @models[:ancestors]
      build_node if @models[:node]
      build_medium if @models[:medium]
      build_vernacular if @models[:vernacular]
      build_occurrence if @models[:occurrence]
      build_trait if @models[:trait]
      # TODO: still need to build agent, ref, attribution, article, image,
      # js_map, link, map, sound, video
    end

    def build_scientific_name
      @models[:scientific_name][:resource_id] = @resource.id
      @models[:scientific_name][:harvest_id] = @harvest.id
      @models[:scientific_name][:node_resource_pk] = @models[:node][:resource_pk]
      prepare_model_for_store(ScientificName, @models[:scientific_name])
    end

    def build_node
      @models[:node][:resource_id] ||= @resource.id
      @models[:node][:harvest_id] ||= @harvest.id
      prepare_model_for_store(Node, @models[:node])
    end

    # TODO: an update of this type might be trickier to handle than I have here.
    # e.g.: The only change on this row was to set "Karninvora" to "Carnivora";
    # we do not unpublish "Karnivora" (rightly, because we don't know whether
    # it's actually used elsewhere), so it will still exist and still be
    # published and will still have children that it shouldn't. But, as
    # mentioned, this is a difficult case to detect.
    def build_ancestors
      ancestry = []
      prev = nil
      Rank.sort(@models[:ancestors].keys).each do |rank|
        ancestor_pk = @models[:ancestors][rank]
        ancestry << ancestor_pk
        # NOTE: @nodes_by_ancestry is just a cache, to make sure we don't redefine things. The value is never used.
        unless @nodes_by_ancestry.key?(ancestry.join('->'))
          begin
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
          rescue => e
            debugger
            puts "phoey!"
          end
          @nodes_by_ancestry[ancestry.join('->')] = true # Remember that we don't need to do this again.
        end
        prev = ancestor_pk
      end
      @models[:node][:parent_resource_pk] = prev
    end

    # NOTE: this can and should fail if there was no node PK or if it's
    # unmatched:
    def build_medium
      debugger unless @models[:medium][:resource_pk]
      node = find_node(@models[:medium])
      @models[:medium][:node_id] = node.id
      @models[:medium][:resource_id] = @resource.id
      @models[:medium][:harvest_id] = @harvest.id
      # TODO: errr... yeah:
      @models[:medium][:guid] = "TODO/#{@resource.id}/#{node_pk}"
      # TODO: Yeah. This too:
      @models[:medium][:base_url] = 'PENDING/TODO'
      # TODO: And licenses:
      @models[:medium][:license_id] = 1
      # TODO: And subclasses:
      @models[:medium][:subclass] = Medium.subclasses[:image] # TODO
      # TODO: And format:
      @models[:medium][:format] = Medium.formats[:jpg]
      # TODO: And owners:
      @models[:medium][:owner] = 'TODO'

      # TODO: there are some other normalizations and checks we should do here.
      prepare_model_for_store(Medium, @models[:medium])
    end

    # NOTE: this is an example of how to pull the resource_pk from another table
    # and attach the model we're building to the associated instance.
    def build_vernacular
      lang_code = @models[:vernacular][:language_code_verbatim]
      lang = find_or_create_language(lang_code)
      node = find_node(@models[:vernacular])
      @models[:vernacular][:node_id] = node.id
      @models[:vernacular][:resource_id] = @resource.id
      @models[:vernacular][:harvest_id] = @harvest.id
      @models[:vernacular][:language_id] = lang.id
      # TODO: there are some other normalizations and checks we should do here,
      # I expect.
      prepare_model_for_store(Vernacular, @models[:vernacular])
    end

    def build_occurrence
      # TODO: node = find_node(@models[:occurrence])
      # TODO: @models[:occurrence][:node_id] = node.id
      @models[:occurrence][:harvest_id] = @harvest.id
      meta = @models[:occurrence].delete(:meta) || {}
      if @models[:occurrence][:sex]
        sex = @models[:occurrence].delete(:sex)
        @models[:occurrence][:sex_term_id] = find_or_create_term(sex).try(:id)
      end
      if @models[:occurrence][:lifestage]
        lifestage = @models[:occurrence].delete(:lifestage)
        @models[:occurrence][:lifestage_term_id] = find_or_create_term(lifestage).try(:id)
      end
      # TODO: there are some other normalizations and checks we should do here,
      # I expect.
      occurrence = prepare_model_for_store(Occurrence, @models[:occurrence])
      meta.each do |key, value|
        datum = {}
        datum[:occurence_id] = occurrence.id
        datum[:predicate_term_id] = find_or_create_term(key).id
        datum = convert_meta_value(datum, value)
        prepare_model_for_store(OccurrenceMetadata, datum)
      end
      # We need to remember these for traits:
      @occurrences[occurrence.resource_pk] = occurrence
    end

    def build_trait
      parent = @models[:trait][:parent_pk]
      occurrence = @models[:trait][:occurrence_resource_pk]
      # TODO: we need to keep a "back reference" of which traits have been hung off of occurrences, because some
      # meta-traits can affect an occurrence and we need to be sure those changes are applied to all associated traits.
      @models[:trait][:resource_id] = @resource.id
      @models[:trait][:harvest_id] = @harvest.id
      if @models[:trait][:of_taxon] && parent
        return log_warning("IGNORING a measurement of a taxon (#{@models[:trait][:resource_pk]}) WITH a parentMeasurementID #{parent}")

      end
      if !@models[:trait][:of_taxon] && parent.blank? && occurrence.blank?
        puts @models[:trait].inspect
        debugger
        return log_warning("IGNORING a measurement NOT of a taxon (#{@models[:trait][:resource_pk]}) with NO parent and NO occurrence ID.")
      end
      # TODO: associations
      predicate = @models[:trait].delete(:predicate)
      # TODO: error handling for predicate ... cannot be blank.
      predicate_term = find_or_create_term(predicate)
      @models[:trait][:predicate_term_id] = predicate_term.id
      units = @models[:trait].delete(:units)
      units_term = find_or_create_term(units)
      @models[:trait][:units_term_id] = units_term.try(:id)

      @models[:trait] = convert_trait_value(@models[:trait])

      if @models[:trait][:statistical_method]
        stat_m = @models[:trait].delete(:statistical_method)
        @models[:trait][:statistical_method_term_id] = find_or_create_term(stat_m).try(:id)
      end
      meta = @models[:trait].delete(:meta) || {}
      trait = prepare_model_for_store(Trait, @models[:trait])
      meta.each do |key, value|
        datum = {}
        datum[:resource_id] = @resource.id
        datum[:harvest_id] = @harvest.id
        datum[:trait_resource_pk] = trait.resource_pk
        predicate_term = find_or_create_term(predicate)
        datum[:predicate_term_id] = predicate_term.id
        datum = convert_meta_value(datum, value)
        prepare_model_for_store(MetaTrait, datum)
      end
    end

    def convert_trait_value(instance)
      value = instance.delete(:value)
      if value =~ URI::regexp
        object_term = find_or_create_term(value)
        instance[:object_term_id] = object_term.id
      end
      if instance[:units]
        units = instance.delete(:units)
        if units =~ URI::regexp
          units_term = find_or_create_term(units)
          instance[:units_term_id] = units_term.id
        else
          # TODO: we need a robust map of strings to reasonable units URIs... though that should be a "filter"
          debugger
          puts "Augh! We don't have a units map for #{units}"
        end
        instance[:measurement] = value
        # NOTE: We are handling unit normalization at the publishing layer for now.
      else
        # TODO: really, we want a robust map of literal values to reasonable URIs, but that should be "filtered".
        instance[:literal] = value
      end
      instance
    end

    # Simpler:
    def convert_meta_value(datum, value)
      if value =~ URI::regexp
        object_term = find_or_create_term(value)
        datum[:object_term_id] = object_term.id
      else
        datum[:literal] = value
      end
      datum
    end

    def find_node(instance)
      node_pk = instance.delete(:node_resource_pk)
      return nil if node_pk.nil? # Nothing to look up!
      # TODO: of course, this is slow... we should queue these up and find them
      # all in one batch. For now, though, this is adequate:
      node = @nodes[node_pk] ||
             Node.where(resource_id: @resource.id, resource_pk: node_pk).first
      debugger if node.nil? # Means that we don't know what this is associated to...
      node
    end

    def find_occurrence(instance)
      pk = instance.delete(:occurrence_resource_pk)
      return nil if pk.nil?
      # TODO: of course, this is slow... we should queue these up and find them
      # all in one batch. For now, though, this is adequate:
      ocrc = @occurrences[pk] ||
             Occurrence.where(resource_id: @resource.id, resource_pk: pk).first
      debugger if ocrc.nil? # Means that we don't know what this is associated to...
      ocrc
    end

    def find_or_create_term(uri)
      return nil if uri.blank?
      # TODO: again, this is slow to do one-at-a-time. We should get a full list
      # and query for all of them:
      term = @terms[uri] || Term.where(uri: uri).first
      if term.nil?
        # Quick and dirty. A Human will have to do better later:
        name = uri.gsub(%r{^.*/}, '').gsub(/[^A-Za-z0-9]+/, ' ')
        term = Term.create(
          uri: uri, name: name, definition: I18n.t("terms.auto_created"),
          comment: "Auto-added during harvest ##{@harvest.id}. "\
            'A human needs to edit this.',
          attribution: @resource.name, is_hidden_from_overview: true,
          is_hidden_from_glossary: true)
        # TODO: This isn't necessarily a problem with the measurements file; it could be the occurrences. :S
        log_warning("Created term for #{uri}!")
      end
      term
    end

    def find_or_create_language(lang_code)
      if Language.exists?(code: lang_code)
        Language.where(code: lang_code).first
      elsif Language.exists?(group_code: lang_code)
        Language.where(group_code: lang_code).first
      else
        Language.create!(code: lang_code, group_code: lang_code)
      end
    end

    # TODO - extract to Store::Storage
    def prepare_model_for_store(klass, model)
      if @diff == :changed
        key = @format.model_fks[klass]
        removed_by_harvest(klass, key, model[key])
      end
      @new[klass] ||= []
      begin
        new_model = klass.send(:new, model)
        @new[klass] << new_model
        new_model
      rescue => e
        debugger
        puts "oopsie."
      end
    end

    # TODO - extract to Store::Storage
    def removed_by_harvest(klass, key, pk)
      @old[klass] ||= {}
      @old[klass][key] ||= []
      @old[klass][key] << pk
    end
  end
end
