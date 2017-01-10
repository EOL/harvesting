module Store
  module Nodes
    def to_nodes_pk(field, val)
      @models[:node] ||= {}
      @models[:node][:resource_pk] = val
    end

    def to_nodes_scientific(field, val)
      @models[:node] ||= {}
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:verbatim] = val
      @models[:node][:name_verbatim] = val
    end

    def to_nodes_parent_fk(field, val)
      @models[:node] ||= {}
      @models[:parent_node] ||= {}
      @models[:parent_node][:resource_pk] = val
    end

    def to_nodes_ancestor(field, val)
      if @ancestors[val]
        @models[:ancestors] << {
          name: val,
          sci_name: @ancestors[val][:sci_name],
          node: @ancestors[val][:node]
        }
      else
        @models[:ancestors] << {
          name: val,
          sci_name: { verbatim: val, resource_id: @resource.id, harvest_id: @harvest.id },
          node: { rank_verbatim: field.submapping, resource_id: @resource.id,
            name_verbatim: val, harvest_id: @harvest.id }
        }
      end
    end

    def to_nodes_rank(field, val)
      @models[:node] ||= { }
      @models[:node][:rank_verbatim] = val
    end

    def to_nodes_further_information_url(field, val)
      @models[:node] ||= { }
      @models[:node][:further_information_url] = val
    end

    def to_taxonomic_status(field, val)
      @models[:scientific_name] ||= { }
      @models[:scientific_name][:taxonomic_status_verbatim] = val
    end

    def to_nodes_remarks(field, val)
      @models[:node] ||= { }
      @models[:node][:remarks] = val
    end

    def to_nodes_publication(field, val)
      @models[:scientific_name] ||= { }
      @models[:scientific_name][:publication] = val
    end

    def to_nodes_source_reference(field, val)
      @models[:scientific_name] ||= { }
      @models[:scientific_name][:source_reference] = val
    end
  end
end
