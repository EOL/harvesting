# TODO: This currently does NOT update things that already exist, and we want it
# to.
module Store
  module ModelBuilder
    def destroy_for_fmt(keys)
      keys.each do |klass, key|
        pk = @models[klass.name.underscore.to_sym][key]
        klass.send(:where, { key => pk, :resource_id => @resource.id }).
          update_attribute(:published, false)
      end
    end

    def build_models(diff, keys)
      build_scientific_name(diff, keys) if @models[:scientific_name]
      build_parent_node(diff, keys) if @models[:parent_node]
      build_node(diff, keys) if @models[:node]
      build_ancestors(diff, keys) unless @models[:ancestors].empty?
      build_medium(diff, keys) if @models[:medium]
      build_vernacular(diff, keys) if @models[:vernacular]
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
          # TODO: issue a warning here that we couldn't (safely) build a parent.
          puts "I cannot build a parent without a (clear) name or prior ref."
          nil
        end
      end
    end

    def build_node(diff, keys)
      node = build_any_node(@models[:node], diff, keys)
      @models[:scientific_name][:node_id] = node.id if @models[:scientific_name]
    end

    # TODO: an update of this type might be trickier to hanlde than I have here.
    # e.g.: The only change on this row was to set "Karninvora" to "Carnivora";
    # we do not unpublish "Karnivora" (rightly, because we don't know whether
    # it's actually used elsewhere), so it will still exist and still be
    # published and will still have children that it shouldn't. But, as
    # mentioned, this is a difficult case to detect.
    def build_ancestors(diff, keys)
      parent_id = 0
      @models[:ancestors].each do |ancestor|
        if ancestor[:node].is_a?(Hash)
          # This is definitely a NEW name/node, otherwise we would have found
          # it, earlier:
          ancestor[:sci_name] = ScientificName.create!(ancestor[:sci_name])
          ancestor[:node][:scientific_name_id] = ancestor[:sci_name].id
          ancestor[:node][:parent_id] = parent_id
          ancestor[:node] = build_any_node(ancestor[:node], :new, keys)
          ancestor[:sci_name].update_attribute(:node_id, ancestor[:node].id)
          @ancestors[ancestor[:name]] = ancestor
          parent_id = ancestor[:node].id
        else
          parent_id = ancestor[:node].id
        end
      end
      if @models[:parent_node]
        if @models[:parent_node].is_a?(Hash)
          # Placeholder--we don't know the Genus name, yet... TODO: we'll have
          # to go back and fill these in once we've parsed these out!
          @models[:parent_node][:scientific_name_id] = 0
          @models[:parent_node][:name_verbatim] = "TODO"
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
      node_pk = @models[:medium].delete(:node_resource_pk)
      # TODO: of course, this is slow... we should queue these up and find them
      # all in one batch. For now, though, this is adequate:
      node = @nodes[node_pk] ||
        Node.where(resource_id: @resource.id, resource_pk: node_pk).first
      @models[:medium][:node_id] = node.id
      @models[:medium][:resource_id] = @resource.id
      @models[:medium][:harvest_id] = @harvest.id
      # TODO: errr... yeah:
      @models[:medium][:guid] = "TODO/#{@resource.id}/#{node_pk}"
      # TODO: Yeah. This too:
      @models[:medium][:base_url] = "PENDING/TODO"
      # TODO: And licenses:
      @models[:medium][:license_id] = 1
      # TODO: And subclasses:
      @models[:medium][:subclass] = Medium.subclasses[:image] # TODO
      # TODO: And format:
      @models[:medium][:format] = Medium.formats[:jpg]
      # TODO: And owners:
      @models[:medium][:owner] = "TODO"

      # TODO: there are some other normalizations and checks we should do here.
      create_or_update(diff, keys, Medium, @models[:medium])
    end

    def build_vernacular(diff, keys)
      node_pk = @models[:vernacular].delete(:node_resource_pk)
      lang_code = @models[:vernacular].delete(:language_code_verbatim)

      lang =
        if Language.exists?(code: lang_code)
          Language.where(code: lang_code).first
        elsif Language.exists?(group_code: lang_code)
          Language.where(group_code: lang_code).first
        else
          Language.create!(code: lang_code, group_code: lang_code)
        end

      # TODO: of course, this is slow... we should queue these up and find them
      # all in one batch. For now, though, this is adequate:
      node = @nodes[node_pk] ||
        Node.where(resource_id: @resource.id, resource_pk: node_pk).first
      debugger if node.nil?
      @models[:vernacular][:node_id] = node.id
      @models[:vernacular][:resource_id] = @resource.id
      @models[:vernacular][:harvest_id] = @harvest.id
      @models[:vernacular][:language_id] = lang.id
      # TODO: there are some other normalizations and checks we should do here,
      # I expect.
      create_or_update(diff, keys, Vernacular, @models[:vernacular])
    end

    def build_any_node(node_hash, diff, keys)
      node_hash[:resource_id] = @resource.id
      node_hash[:harvest_id] = @harvest.id
      node = create_or_update(diff, keys, Node, node_hash)
      @nodes[node.resource_pk] = node
      node
    end

    def create_or_update(diff, keys, klass, model)
      if diff == :changed
        key = keys[klass]
        pk = model[key]
        klass.send(:where, { key => pk, :resource_id => @resource.id }).
          update_all(removed_by_harvest_id: @harvest.id)
      end
      klass.send(:create!, model)
    end
  end
end
