class Vernacular < ActiveRecord::Base
  belongs_to :resource, inverse_of: :vernaculars
  belongs_to :harvest, inverse_of: :vernaculars
  belongs_to :node, inverse_of: :vernaculars
  belongs_to :language

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
