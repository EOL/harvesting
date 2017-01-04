# TODO: This currently does NOT update things that already exist, and we want it
# to.
module Store
  module ModelBuilder
    def build_models
      build_scientific_name if @models[:scientific_name]
      build_parent_node if @models[:parent_node]
      build_node if @models[:node]
      build_ancestors unless @models[:ancestors].empty?
      build_medium if @models[:medium]
      build_vernacular if @models[:vernacular]
    end

    def build_scientific_name
      @models[:scientific_name][:resource_id] = @resource.id
      sci_name = ScientificName.create!(@models[:scientific_name])
      @models[:node][:scientific_name_id] = sci_name.id if @models[:node]
    end

    def build_parent_node
      @models[:parent_node][:resource_id] = @resource.id
      if @models[:parent_node][:scientific_name_id]
        parent = Node.create!(@models[:parent_node])
        @models[:node][:parent_id] = parent.id if @models[:node]
        parent
      else
        if parent = @nodes[@models[:parent_node].resource_pk]
          @models[:node][:parent_id] = parent.id if @models[:node]
          parent
        else
          # TODO: issue a warning here that we couldn't (safely) build a parent.
          puts "I cannot build a parent without a (clear) name or prior ref."
          nil
        end
      end
    end

    def build_node
      @models[:node][:resource_id] = @resource.id
      node = Node.create!(@models[:node])
      @nodes[node.resource_pk] = node
      @models[:scientific_name][:node_id] = node.id if @models[:scientific_name]
    end


    # YOU WERE HERE : I was in the middle of changing the models to hashes, and
    # I stopped here. This one is a little tricky because of the lookups its
    # doing on other ancestors, so be careful.
    
    def build_ancestors
      parent_id = 0
      @models[:ancestors].each do |ancestor|
        if ancestor[:node].new_record?
          ancestor[:sci_name].save!
          ancestor[:node].scientific_name_id = ancestor[:sci_name].id
          ancestor[:node].parent_id = parent_id
          ancestor[:node].save!
          @ancestors[ancestor[:name]] = ancestor
        end
        parent_id = ancestor[:node].id
      end
      if @models[:parent_node]
        if @models[:parent_node].new_record?
          puts "WARNING: can't update parent node with parent_id #{parent_id}!"
        else
          @models[:parent_node].update_attribute(:parent_id, parent_id)
        end
      else
        @models[:node].update_attribute(:parent_id, parent_id)
      end
    end

    # NOTE: this can and should fail if there was no node PK or if it's
    # unmatched:
    def build_medium
      node_pk = @models[:medium].delete(:node_resource_pk)
      # TODO: of course, this is slow... we should queue these up and find them
      # all in one batch. For now, though, this is adequate:
      node = @nodes[node_pk] ||
        Node.where(resource_id: @resource.id, resource_pk: node_pk).first
      @models[:medium][:node_id] = node.id
      @models[:medium][:resource_id] = @resource.id
      @models[:medium][:resource_pk] = node_pk
      # TODO: errr... yeah:
      @models[:medium][:guid] = "TODO/#{@resource.id}/#{node_pk}"
      # TODO: Yeah. This too:
      @models[:medium][:base_url] = "PENDING"
      # TODO: And licenses:
      @models[:medium][:license_id] = 1
      # TODO: And subclasses:
      @models[:medium][:subclass] = Medium.subclasses[:image]
      # TODO: And format:
      @models[:medium][:format] = Medium.formats[:jpg]
      # TODO: And owners:
      @models[:medium][:owner] = "TODO"

      # TODO: there are some other normalizations and checks we should do here.
      Medium.create!(@models[:medium])
    end

    def build_vernacular
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
      @models[:vernacular][:node_id] = node.id
      @models[:vernacular][:resource_id] = @resource.id
      @models[:vernacular][:language_id] = lang.id
      # TODO: there are some other normalizations and checks we should do here,
      # I expect.
      Vernacular.create!(@models[:vernacular])
    end
  end
end
