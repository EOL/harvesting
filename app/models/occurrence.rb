# An occurrence from the resource file. We don't actually "need" these, per se;
# this is used as a holding-place for information which we'll use to build
# traits, later.
class Occurrence < ActiveRecord::Base
  belongs_to :harvest, inverse_of: :occurrences
  belongs_to :node, inverse_of: :occurrences

  has_many :traits, inverse_of: 'occurrence'
  has_many :assocs, inverse_of: 'occurrence'
  has_many :occurrence_metadata, inverse_of: :occurrence

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
