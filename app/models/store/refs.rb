module Store
  module Refs
    def to_refs_pk(field, val)
      @models[:ref] ||= {}
      @models[:ref][:resource_pk] = val
    end

    def to_refs_body(field, val)
      @models[:ref] ||= {}
      @models[:ref][:body] = val
    end

    def to_refs_part(field, val)
      @models[:ref] ||= {}
      @models[:ref][:parts] ||= []
      @models[:ref][:parts] << val
    end

    def to_refs_url(field, val)
      @models[:ref] ||= {}
      @models[:ref][:url] = val
    end

    def to_refs_doi(field, val)
      @models[:ref] ||= {}
      @models[:ref][:doi] = val
    end
  end
end
