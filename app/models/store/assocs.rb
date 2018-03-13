module Store
  module Assocs
    def to_associations_pk(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:resource_pk] = val
    end

    def to_associations_occurrence_fk(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:occurrence_resource_fk] = val
    end

    def to_associations_target_occurrence_fk(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:target_occurrence_resource_fk] = val
    end

    def to_associations_predicate(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:predicate] = val
    end

    def to_associations_source(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:source] = val
    end

    def to_associations_ref_fks(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:ref_sep] ||= field.submapping
      @models[:assoc][:ref_fks] = val
    end

    def to_associations_meta(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:meta] ||= {}
      @models[:assoc][:meta][field.submapping] = val
    end

    def to_traits_attributions_fk(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:attributions] ||= []
      @models[:assoc][:attributions] << val
    end
  end
end
