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
      @models[:scientific_name].resource_id = @resource.id
      @models[:scientific_name].save!
      @models[:node].scientific_name_id =
        @models[:scientific_name].id if @models[:node]
    end

    def build_parent_node
      @models[:parent_node].resource_id = @resource.id
      if @models[:parent_node].scientific_name_id
        @models[:parent_node].save
        @models[:node].parent_id = @models[:parent_node].id if
          @models[:node]
      else
        if parent = @nodes[@models[:parent_node].resource_pk]
          @models[:node].parent_id = parent.id
        else
          # TODO: issue a warning here that we couldn't (safely) build a parent.
          puts "I cannot build a parent without a (clear) name or prior ref."
        end
      end
    end

    def build_node
      @models[:node].resource_id = @resource.id
      @models[:node].save!
      @nodes[@models[:node].resource_pk] = @models[:node]
      @models[:scientific_name].update_attribute(:node_id,
        @models[:node].id) if @models[:scientific_name]
    end

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
      node_fk = @models[:medium].delete(:node_resource_pk)
      # TODO: of course, this is slow... we should queue these up and find them
      # all in one batch. For now, though, this is adequate:
      node = @nodes[node_fk] ||
        Node.where(resource_id: @resource.id, resource_pk: node_fk)
      @models[:medium][:node_id] = node.id
      @models[:medium][:resource_id] = @resource.id
      # TODO: errr... yeah:
      @models[:medium][:guid] = "TODO/#{@resource.id}/#{node_fk}"
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
      node_fk = @models[:vernacular].delete(:node_resource_pk)
      # TODO: of course, this is slow... we should queue these up and find them
      # all in one batch. For now, though, this is adequate:
      node = @nodes[node_fk] ||
        Vernacular.where(resource_id: @resource.id, resource_pk: node_fk)
      @models[:vernacular][:node_id] = node.id
      @models[:vernacular][:resource_id] = @resource.id
      # TODO: there are some other normalizations and checks we should do here,
      # including some handling of languages, I expect.
      Vernacular.create!(@models[:vernacular])
    end
  end
end
