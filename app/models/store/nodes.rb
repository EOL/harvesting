module Store
  module Nodes
    def to_nodes_pk(_, val)
      @models[:node] ||= {}
      @models[:node][:resource_pk] = val
    end

    def to_nodes_page_id(_, val)
      @models[:node] ||= {}
      return if val.blank?
      if val.downcase.sub(/^\s+/, '').sub(/\s+$/, '') == 'new'
        @models[:node][:page_id] = 0 # This is a LITTLE dangerous, but a "0" here will mean "map this to a NEW page,
                                     # don't attempt to match this to any other node."
      else
        raise "Non-integer page_id!" if val.to_i.zero?
        @models[:node][:page_id] = val
      end
    end

    def to_nodes_landmark(field, val)
      @models[:node] ||= {}
      landmark = Node.landmarks.keys[val.to_i]
      @process.debug("Set landmark to #{landmark}") if field.debugging
      @models[:node][:landmark] = landmark
    end

    def to_nodes_scientific(field, val)
      @models[:node] ||= {}
      @models[:scientific_name] ||= {}
      # Get rid of surrounding quotes quietly:
      no_quotes = val =~ /^".*"$/ ? val.sub(/^"/, '').sub(/"$/, '') : val
      # If there are any OTHER unusual characters (incl. more quotes), carp about it, but fix them:
      name = no_quotes.gsub(%r{[\"\/\\]}, '').gsub(%r{\s+}, ' ')
      if name != no_quotes
        @no_quote_warning_count ||= 0
        @no_quote_warning_count += 1
        if @no_quote_warning_count < 30
          @models[:log] ||= []
          @models[:log] << "Filtered Scientific Name \`#{no_quotes}\` to \`#{name}\`"
        elsif @no_quote_warning_count == 30
          @models[:log] ||= []
          @models[:log] << '(Reached filtered-name limit; supressing further warnings.)'
        end
      end
      @process.debug("Set verbatim to #{name}") if field.debugging
      @models[:scientific_name][:verbatim] = name
    end

    def to_nodes_parent_fk(field, val)
      @models[:node] ||= {}
      # It seems the intent of a '0' in this column really is a blank, since there are no IDs that match '0' in these
      # resources.
      if val == '0'
        val = nil
        @process.debug('changed parent_resource_pk to nil because it was "0"') if field.debugging
      end
      @models[:node][:parent_resource_pk] = val
    end

    def to_nodes_ancestor(field, val)
      @models[:ancestors] ||= {}
      @models[:ancestors][field.submapping] = val
      @process.debug("Set node #{field.submapping}.") if field.debugging
    end

    def to_nodes_rank(_, val)
      @models[:node] ||= {}
      @models[:node][:rank_verbatim] = val
    end

    def to_nodes_further_information_url(_, val)
      @models[:node] ||= {}
      @models[:node][:further_information_url] = val
    end

    def to_nodes_dataset_id(_, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:dataset_id] = val
    end

    def to_taxonomic_status(_, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:taxonomic_status_verbatim] = val
    end

    def to_nodes_ref_fks(field, val)
      @models[:node] ||= {}
      @models[:node][:ref_sep] ||= field.submapping
      @process.debug("Set node ref_sep to #{field.submapping}") if field.debugging
      @models[:node][:ref_fks] = val
    end

    def to_nodes_accepted_name_fk(field, val)
      # TODO: What we really want to do here is, if there is a value here, move all of the fields from the node to the
      # scientific name, but that's hairy and I don't want to do it right now. Soon.
      @models[:scientific_name] ||= {}
      if accepted_name_is_synonym?(val)
        # NOTE: no, we cannot create a synonym object here, because there may be other methods invoked that will add to
        # the scientific name, and I don't want to write branching code in every one of them. This will be handled by
        # the model builder:
        @models[:scientific_name][:synonym_of] = val
        @process.debug("Set node synonym_of because accepted_name_is_synonym") if field.debugging
      else
        # Really, nothing to do. It's a normal row, treat it normally.
        @process.debug("skipping synonym_of because accepted_name_is_synonym is FALSE") if field.debugging
      end
    end

    # KS: "Note that a few data sets have acceptedNameUsageID values also for preferred names, in those cases
    # acceptedNameUsageID=taxonID for preferred names and acceptedNameUsageID≠taxonID for non-preferred names"
    def accepted_name_is_synonym?(val)
      @models[:node] && @models[:node][:resource_pk] && @models[:node][:resource_pk] != val
    end

    def to_nodes_remarks(_, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:remarks] = val
    end

    def to_nodes_publication(_, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:publication] = val
    end

    def to_nodes_source_ref_fk(_, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:ref_fk] = val
    end

    def to_nodes_identifiers(_, val)
      @models[:identifiers] ||= []
      @models[:identifiers] += val.split(/,\s*/)
    end

    def to_nodes_dataset_name(_, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:dataset_name] = val
    end

    def to_nodes_name_according_to(_, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:name_according_to] = val
    end
  end
end
