module Store
  module Occurrence
    def to_occurrences_pk(field, val)
      @models[:occurrence] ||= {}
      @models[:occurrence][:resource_pk] = val
    end
  end
end
