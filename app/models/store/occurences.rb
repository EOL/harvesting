module Store
  module Occurrences
    def to_occurrences_pk(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:resource_pk] = val
    end

    def to_occurrences_node(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:node_resource_pk] = val
    end

    def to_occurrences_sex(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:sex] = val
    end

    def to_occurrences_lifestage(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:lifestage] = val
    end

    def to_occurrences_lat(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:lat] = val
    end

    def to_occurrences_long(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:long] = val
    end

    def to_occurrences_locality(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:locality] = val
    end

    def to_occurrences_meta(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:meta] ||= {}
      @models[:occurrence][:meta][field.submapping] = val
    end
  end
end
