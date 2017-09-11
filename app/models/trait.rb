# An measurement formed by combining a "measurment or fact" with an "occurrence".
class Trait < ActiveRecord::Base
  belongs_to :resource, inverse_of: :traits
  belongs_to :harvest, inverse_of: :traits
  belongs_to :node, inverse_of: :traits

  has_many :meta_traits, inverse_of: :trait

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
