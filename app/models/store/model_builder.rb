module Store
  module ModelBuilder
    def destroy_for_fmt(keys)
      keys.each do |klass, key|
        removed_by_harvest(klass, key,
          @models[klass.name.underscore.to_sym][key])
      end
    end

    def build_models(diff, keys)
      build_scientific_name(diff, keys) if @models[:scientific_name]
      build_parent_node(diff, keys) if @models[:parent_node]
      build_ancestors(diff, keys) unless @models[:ancestors].empty?
      build_node(diff, keys) if @models[:node]
      build_medium(diff, keys) if @models[:medium]
      build_vernacular(diff, keys) if @models[:vernacular]
      build_occurrence(diff, keys) if @models[:occurrence]
      build_trait(diff, keys) if @models[:data_record]
      # TODO: still need to build agent, ref, attribution, article, image,
      # js_map, link, map, sound, video

    end

    def build_scientific_name(diff, keys)
      @models[:scientific_name][:resource_id] = @resource.id
      @models[:scientific_name][:harvest_id] = @harvest.id
      sci_name = create_or_update(diff, keys, ScientificName, @models[:scientific_name])
      @models[:node][:scientific_name_id] = sci_name.id if @models[:node]
    end

    def build_parent_node(diff, keys)
      @models[:parent_node][:resource_id] = @resource.id
      @models[:parent_node][:harvest_id] = @harvest.id
      if @models[:parent_node][:scientific_name_id]
        parent = create_or_update(diff, keys, Node, @models[:parent_node])
        @models[:node][:parent_id] = parent.id if @models[:node]
        parent
      else
        parent_fk = @models[:parent_node].is_a?(Hash) ?
          @models[:parent_node][:resource_pk] :
          @models[:parent_node].resource_pk
        if parent = @nodes[parent_fk]
          @models[:node][:parent_id] = parent.id if @models[:node]
          parent
        else
          # TODO: move this to a warning.
          puts "I cannot build a parent without a (clear) name or prior ref."
          nil
        end
      end
    end

    def build_node(diff, keys)
      node = build_any_node(@models[:node], diff, keys)
      @models[:scientific_name][:node_id] = node.id if @models[:scientific_name]
    end

    # TODO: an update of this type might be trickier to handle than I have here.
    # e.g.: The only change on this row was to set "Karninvora" to "Carnivora";
    # we do not unpublish "Karnivora" (rightly, because we don't know whether
    # it's actually used elsewhere), so it will still exist and still be
    # published and will still have children that it shouldn't. But, as
    # mentioned, this is a difficult case to detect.
    def build_ancestors(diff, keys)
      parent_id = 0
      @models[:ancestors].each do |ancestor|
        parent_id =
          if ancestor[:node].is_a?(Hash)
            # This is definitely a NEW name/node, otherwise we would have found
            # it, earlier:
            ancestor[:sci_name] = ScientificName.create!(ancestor[:sci_name])
            ancestor[:node][:scientific_name_id] = ancestor[:sci_name].id
            ancestor[:node][:parent_id] = parent_id
            ancestor[:node] = build_any_node(ancestor[:node], :new, keys)
            ancestor[:sci_name].update_attribute(:node_id, ancestor[:node].id)
            @ancestors[ancestor[:name]] = ancestor
            ancestor[:node].id
          else
            ancestor[:node].id
          end
      end
      if @models[:parent_node]
        if @models[:parent_node].is_a?(Hash)
          # Placeholder--we don't know the Genus name, yet... TODO: we'll have
          # to go back and fill these in once we've parsed these out!
          @models[:parent_node][:scientific_name_id] = 0
          @models[:parent_node][:name_verbatim] = 'TODO'
          @models[:parent_node][:parent_id] = parent_id
          @models[:parent_node] =
            build_any_node(@models[:parent_node], :new, keys)
          @models[:node][:parent_id] = @models[:parent_node].id
        else
          @models[:parent_node].update_attribute(:parent_id, parent_id)
        end
      else
        @models[:node][:parent_id] = parent_id
      end
    end

    # NOTE: this can and should fail if there was no node PK or if it's
    # unmatched:
    def build_medium(diff, keys)
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
      create_or_update(diff, keys, Medium, @models[:medium])
    end

    # NOTE: this is an example of how to pull the resource_pk from another table
    # and attach the model we're building to the associated instance.
    def build_vernacular(diff, keys)
      lang_code = @models[:vernacular][:language_code_verbatim]
      lang = find_or_create_language(lang_code)
      node = find_node(@models[:vernacular])
      @models[:vernacular][:node_id] = node.id
      @models[:vernacular][:resource_id] = @resource.id
      @models[:vernacular][:harvest_id] = @harvest.id
      @models[:vernacular][:language_id] = lang.id
      # TODO: there are some other normalizations and checks we should do here,
      # I expect.
      create_or_update(diff, keys, Vernacular, @models[:vernacular])
    end

    def build_occurrence(diff, keys)
      node = find_node(@models[:occurrence])
      @models[:occurrence][:node_id] = node.id
      @models[:occurrence][:harvest_id] = @harvest.id
      meta = @models[:occurrence].delete(:meta) || {}
      if @models[:occurrence][:sex]
        sex = @models[:occurrence].delete(:sex)
        @models[:occurrence][:sex_term_id] = find_or_create_term(sex)
      end
      if @models[:occurrence][:lifestage]
        lifestage = @models[:occurrence].delete(:lifestage)
        @models[:occurrence][:lifestage_term_id] = find_or_create_term(lifestage)
      end
      # TODO: there are some other normalizations and checks we should do here,
      # I expect.
      occurrence = create_or_update(diff, keys, Occurrence, @models[:occurrence])
      meta.each do |key, value|
        datum = {}
        datum[:occurence_id] = occurrence.id
        datum[:predicate_term_id] = find_or_create_term(key)
        datum[:value] = value
        create_or_update(diff, keys, OccurrenceMetadata, datum)
      end
      # We need to remember these for traits:
      @occurrences[occurrence.resource_pk] = occurrence
    end

    def build_trait(diff, keys)
      parent = @models[:trait][:trait_resource_pk]
      occurrence = find_occurrence(@models[:trait])
      # TODO: we need to keep a "back reference" of which traits have been hung off of occurrences, because some
      # meta-traits can affect an occurrence and we need to be sure those changes are applied to all associated traits.
      @models[:trait][:resource_id] = @resource.id
      @models[:trait][:harvest_id] = @harvest.id
      if @models[:trait][:of_taxon]
        if parent
          @format.warn("IGNORING a measurement of a taxon WITH a parentMeasurementID #{parent}")
        else
          # This is a "normal" trait.
          object_node = find_node(@models[:trait])
          @models[:trait][:object_node_id] = object_node.id if object_node
          predicate = @models[:trait].delete(:predicate)
          # TODO: error handling for predicate ... cannot be blank.
          predicate_term = find_or_create_term(predicate)
          @models[:trait][:predicate_term_id] = predicate_term.id

          @models[:trait] = convert_trait_value(@models[:trait])
          # TODO:
          if @models[:trait][:statistical_method]
            stat_m = @models[:trait].delete(:statistical_method)
            @models[:trait][:statistical_method_term_id] = find_or_create_term(stat_m)
          end
          # TODO: get the info from the occurrence (sex, lifestage, meta) and add it here...
          trait = create_or_update(diff, keys, Trait, @models[:trait])
        end
      else # This is metadata...
        # TODO (long-term): allow meta-meta data. Right now we cannot do that.
        @models[:trait] = convert_trait_value(@models[:trait])
        if parent
          # Metadata of a "normal" trait...
          # Grab the predicate
          # grab the value (various types)
          # grab the units (if there are any)
          # Add it to the metadata of the trait
        elsif occurrence
          # This is metadata of an occurrence (e.g.: saying that it was down by trawl)

          # TODO: shoot. We're going to have to be careful here and look for occurrances which have "already been used,"
          # and add these metadata to those traits. Tricky, tricky. :S

        else
          @format.warn("IGNORING a measurement NOT of a taxon with NO parent and NO occurrence ID.")
        end
      end
      # TODO: add metadata... Sheesh.
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
      # TODO: again, this is slow to do one-at-a-time. We should get a full list
      # and query for all of them:
      term = @terms[uri] || Term.where(uri: uri)
      if term.nil?
        # Quick and dirty. A Human will have to do better later:
        name = uri.gsub(%r{^.*/}, '').gsub(/[^A-Za-z0-9]+/, ' ')
        term = Term.create(
          uri: uri, name: name, definiton: '',
          comment: "Auto-added during harvest ##{@harvest.id}. "\
            'A human needs to edit this.',
          attribution: @resource.name, is_hidden_from_overview: true,
          is_hidden_from_glossary: true)
        # TODO: we need some kind of warning in the log or something.
        @format.warn("Created term for #{uri}!")
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

    def build_any_node(node_hash, diff, keys)
      node_hash[:resource_id] = @resource.id
      node_hash[:harvest_id] = @harvest.id
      node_hash[:resource_pk] ||= node_hash[:name_verbatim]
      # Node already existed, just update it and pass that back:
      node =
        if @nodes[node_hash[:resource_pk]]
          @nodes[node_hash[:resource_pk]].update_attributes(node_hash)
          @nodes[node_hash[:resource_pk]]
        else
          n = create_or_update(diff, keys, Node, node_hash)
          @nodes[n.resource_pk] = n
        end

      debugger if node.resource_pk.blank? # Shouldn't happen! :S
      node
    end

    def create_or_update(diff, keys, klass, model)
      if diff == :changed
        key = keys[klass]
        removed_by_harvest(klass, key, model[key])
      end
      klass.send(:create!, model)
    end

    def removed_by_harvest(klass, key, pk)
      klass.send(:where, { key => pk, :resource_id => @resource.id }).
        update_all(removed_by_harvest_id: @harvest.id)
    end
  end
end
