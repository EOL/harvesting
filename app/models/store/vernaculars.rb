module Store
  module Vernaculars
    def to_vernacular_nodes_fk(field, val)
      @models[:vernacular] ||= { }
      @models[:vernacular][:node_resource_pk] = val
    end

    def to_vernaculars_verbatim(field, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:verbatim] = val
    end

    def to_vernaculars_language(field, val)
      @models[:vernacular] ||= {}
      # TODO: we will have more to do, since we "know" this is ISO 639.1, but
      # right now we just store it and that's fine:
      @models[:vernacular][:language_code_verbatim] = val
    end

    def to_vernaculars_preferred(field, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:is_preferred] = Store.is_truthy?(val)
    end

    def to_vernaculars_remarks(field, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:remarks] = val
    end

    def to_vernaculars_source(field, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:source] = val
    end
  end
end
