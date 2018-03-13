module Store
  module Attributions
    def to_attributions_pk(_, val)
      @models[:attribution] ||= {}
      @models[:attribution][:resource_pk] = val
    end

    def to_attributions_name(_, val)
      @models[:attribution] ||= {}
      @models[:attribution][:name] = val
    end

    def to_attributions_role(_, val)
      @models[:attribution] ||= {}
      @models[:attribution][:role] = val
    end

    def to_attributions_email(_, val)
      @models[:attribution] ||= {}
      @models[:attribution][:email] = val
    end

    def to_attributions_url(_, val)
      @models[:attribution] ||= {}
      @models[:attribution][:url] = val
    end

    def to_attributions_other(field, val)
      @models[:attribution] ||= {}
      @models[:attribution][:other_info] ||= {}
      @models[:attribution][:other_info][field.submapping] = val
    end
  end
end
