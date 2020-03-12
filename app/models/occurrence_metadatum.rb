class OccurrenceMetadatum < ApplicationRecord
  belongs_to :harvest, inverse_of: :occurrence_metadata
  belongs_to :occurrence, inverse_of: :occurrence_metadata
  belongs_to :predicate_term, class_name: 'Term'
  belongs_to :object_term, class_name: 'Term'
  belongs_to :units_term, class_name: 'Term'
  belongs_to :statistical_method_term, class_name: 'Term'
end
