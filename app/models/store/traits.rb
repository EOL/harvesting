module Store
  module Traits
    def to_traits_pk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:resource_pk] = val
    end

    def to_traits_occurrence_fk(_, val)
      @models[:trait] ||= {}
      return if @models[:trait][:parent_pk] # Not allowed! Ignore it.
      @models[:trait][:occurrence_resource_pk] = val
    end

    def to_traits_measurement_of_taxon(_, val)
      @models[:trait][:of_taxon] = looks_true?(val)
    end

    def to_traits_parent_pk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:occurrence_resource_pk] = nil # Not allowed!
      @models[:trait][:parent_pk] = val
    end

    def to_traits_predicate(_, val)
      @models[:trait] ||= {}
      @models[:trait][:predicate] = val
    end

    def to_traits_value(_, val)
      @models[:trait] ||= {}
      @models[:trait][:value] = val
    end

    def to_traits_units(_, val)
      @models[:trait] ||= {}
      @models[:trait][:units] = val
    end

    def to_traits_statistical_method(_, val)
      @models[:trait] ||= {}
      @models[:trait][:statistical_method] = val
    end

    def to_traits_source(_, val)
      @models[:trait] ||= {}
      @models[:trait][:source] = val
    end

    def to_traits_ref_fks(field, val)
      @models[:trait] ||= {}
      @models[:trait][:ref_sep] ||= field.submapping
      @models[:trait][:ref_fks] = val
    end

    def to_traits_assoc_node_fk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:assoc_resource_pk] = val
    end

    def to_traits_meta(field, val)
      @models[:trait] ||= {}
      @models[:trait][:meta] ||= {}
      @models[:trait][:meta][field.submapping] = val
    end

    # NOTE: JH said it's okay to skip these for MVP.
    # def to_traits_attributions_fk(field, val)
    # end
  end
end
