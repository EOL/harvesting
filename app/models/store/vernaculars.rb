module Store
  module Vernaculars
    def to_nodes_pk(field, val)
      @models[:node] ||= Node.new
      @models[:node].resource_pk = val
    end

    def to_vernaculars_verbatim(field, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:verbatim] = val
    end

    def to_language_639_1(field, val)
      @models[:vernacular] ||= {}
      # TODO: we will have more to do, since we "know" this is ISO 639.1, but
      # right now we just store it and that's fine:
      @models[:vernacular][:language_code_verbatim] = val
    end

    def to_vernaculars_preferred(field, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:is_preferred] = Store.is_truthy?(val)
    end
  end
end
