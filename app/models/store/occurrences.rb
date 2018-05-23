module Store
  module Occurrences
    def to_occurrences_pk(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:resource_pk] = val
    end

    def to_occurrences_nodes_fk(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:node_resource_pk] = val
    end

    def to_occurrences_sex(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:sex] = get_sex(val)
    end

    def to_occurrences_lifestage(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:lifestage] = get_lifestage(val)
    end

    def get_sex(uri)
      @sexes ||= {}
      get_meta_field(@sexes, uri, 'http://rs.tdwg.org/dwc/terms/sex')
    end

    def get_lifestage(uri)
      @lifestages ||= {}
      get_meta_field(@lifestages, uri, 'http://rs.tdwg.org/dwc/terms/lifeStage')
    end

    def get_meta_field(cache, uri, meta_uri)
      return uri unless uri =~ URI::ABS_URI
      @models[:occurrence][:meta] ||= {}
      @models[:occurrence][:meta][meta_uri] = uri
      uri
    end

    def to_occurrences_lat(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:meta] ||= {}
      @models[:occurrence][:meta]["http://rs.tdwg.org/dwc/terms/decimalLatitude"] = val
    end

    def to_occurrences_long(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:meta] ||= {}
      @models[:occurrence][:meta]["http://rs.tdwg.org/dwc/terms/decimalLongitude"] = val
    end

    def to_occurrences_lat_literal(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:meta] ||= {}
      @models[:occurrence][:meta]["http://rs.tdwg.org/dwc/terms/verbatimLatitude"] = val
    end

    def to_occurrences_long_literal(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:meta] ||= {}
      @models[:occurrence][:meta]["http://rs.tdwg.org/dwc/terms/verbatimLongitude"] = val
    end

    def to_occurrences_locality(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:meta] ||= {}
      @models[:occurrence][:meta]["http://rs.tdwg.org/dwc/terms/locality"] = val
    end

    def to_occurrences_meta(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:meta] ||= {}
      @models[:occurrence][:meta][field.submapping] = val
    end
  end
end
