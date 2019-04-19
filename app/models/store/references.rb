module Store
  module References
    def to_refs_pk(field, val)
      @models[:reference] ||= {}
      @models[:reference][:resource_pk] = val
    end

    def to_refs_body(field, val)
      @models[:reference] ||= {}
      @models[:reference][:body] = remove_emojis(val)
    end

    def to_refs_part(field, val)
      @models[:reference] ||= {}
      @models[:reference][:parts] ||= []
      @models[:reference][:parts] << val
    end

    def to_refs_url(field, val)
      @models[:reference] ||= {}
      @models[:reference][:url] = val
    end

    def to_refs_doi(field, val)
      @models[:reference] ||= {}
      @models[:reference][:doi] = val
    end
  end
end
