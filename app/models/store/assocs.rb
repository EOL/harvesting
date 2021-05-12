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
      @process.debug("Set ref_sep to #{field.submapping}") if field.debugging
      @models[:assoc][:ref_fks] = val
    end

    def to_associations_contributor(_, val)
      @models[:assoc] ||= {}
      @models[:assoc][:contributor] = val
    end

    def to_associations_determined_by(_, val)
      @models[:assoc] ||= {}
      @models[:assoc][:determined_by] = val
    end

    def to_associations_compiler(_, val)
      @models[:assoc] ||= {}
      @models[:assoc][:compiler] = val
    end

    def to_associations_meta(field, val)
      @models[:assoc] ||= {}
      @models[:assoc][:meta] ||= {}
      @process.debug("Set meta #{field.submapping} value") if field.debugging
      @models[:assoc][:meta][field.submapping] = val
    end

    # NOTE: JH said it's okay to skip these for MVP.
    # def to_traits_attributions_fk(field, val)
    # end
  end
end
