# An occurrence from the resource file. We don't actually "need" these, per se;
# this is used as a holding-place for information which we'll use to build
# traits, later.
class Occurrence < ApplicationRecord
  belongs_to :harvest, inverse_of: :occurrences
  belongs_to :node, inverse_of: :occurrences

  has_many :traits, inverse_of: 'occurrence'
  has_many :assocs, inverse_of: 'occurrence'
  has_many :occurrence_metadata, inverse_of: :occurrence # NOTE: ooof. As of May 2018, this is SLOOOOW. Index?

  scope :harvested, -> { where(removed_by_harvest_id: nil) }
end
