module Store
  module Vernaculars
    def to_vernacular_nodes_fk(_, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:node_resource_pk] = val
    end

    def to_vernaculars_verbatim(_, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:verbatim] = remove_emojis(val)
    end

    def to_vernaculars_language(field, val)
      @models[:vernacular] ||= {}
      lang = val.dup
      lang = field.submapping if lang.blank?
      @models[:vernacular][:language_code_verbatim] = lang
      @process.debug("Set vernacular language_code_verbatim to #{lang}") if field.debugging
    end

    def to_vernaculars_preferred(field, val)
      @models[:vernacular] ||= {}
      is_preferred = Store.is_truthy?(val)
      @process.debug("Set is_preferred to #{is_preferred} (from {#{val}})") if field.debugging
      @models[:vernacular][:is_preferred] = is_preferred
    end

    def to_vernaculars_remarks(_, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:remarks] = val
    end

    def to_vernaculars_source(_, val)
      @models[:vernacular] ||= {}
      @models[:vernacular][:source] = val
    end
  end
end
