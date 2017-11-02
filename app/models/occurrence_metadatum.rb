class OccurrenceMetadatum < ActiveRecord::Base
  belongs_to :harvest, inverse_of: :occurrence_metadata
  belongs_to :occurrence, inverse_of: :occurrence_metadata
  belongs_to :predicate_term, class_name: 'Term'
  belongs_to :object_term, class_name: 'Term'
end
