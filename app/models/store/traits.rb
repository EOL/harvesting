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
      # TODO: generalize EOL's "truthiness"
      val = val =~ /^[ty1+]/i ||   # Trying to capture "true", "yes", "1", and "+", here.
            val =~ /(true|yes)$/i  # ...and this is meant for "URIs" that end in these terms.
      @models[:trait][:of_taxon] = val ? true : false
    end

    def to_traits_parent_pk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:occurrence_resource_pk] = nil # Not allowed!
      @models[:trait][:parent_pk] = val
    end

    def to_traits_association_node_fk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:association_resource_pk] = val
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

    def to_traits_reference_fk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:reference_fk] = val
    end

    def to_traits_meta(field, val)
      @models[:trait] ||= {}
      @models[:trait][:meta] ||= {}
      @models[:trait][:meta][field.submapping] = val
    end
  end
end
