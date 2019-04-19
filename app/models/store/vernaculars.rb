module Store
  module Vernaculars
    def to_vernacular_nodes_fk(field, val)
      @models[:vernacular] ||= { }
      @models[:vernacular][:node_resource_pk] = val
    end

    def to_vernaculars_verbatim(field, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:verbatim] = remove_emojis(val)
    end

    def to_vernaculars_language(field, val)
      @models[:vernacular] ||= {}
      lang = val.dup
      lang = field.submapping if lang.blank?
      @models[:vernacular][:language_code_verbatim] = lang
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
      @models[:vernacular][:source] = val # TODO: I actually think this is supposed to be a reference ID, but I'm not sure.
    end

    def remove_emojis
  end
end
