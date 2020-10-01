class OccurrenceMetadatum < ApplicationRecord
  belongs_to :harvest, inverse_of: :occurrence_metadata
  belongs_to :occurrence, inverse_of: :occurrence_metadata
end
