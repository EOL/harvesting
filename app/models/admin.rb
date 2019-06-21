# A place to stick some code useful for administration, but not really related to the code per-se.
class Admin
  class << self
    def optimize_tables
      %w[vernaculars traits traits_references scientific_names resources references occurrences
         occurrence_metadata nodes_references nodes node_ancestors media media_references locations
         identifiers hlogs harvests formats fields content_attributions bibliographic_citations
         attributions assocs_references assocs assoc_traits articles].each do |table|
           Node.connection.execute("OPTIMIZE TABLE `#{table}`")
         end
    end
  end
end
