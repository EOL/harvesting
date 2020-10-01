# An measurement formed by combining a "measurment or fact" with an "association"
class AssocTrait < ApplicationRecord
  belongs_to :resource, inverse_of: :assoc_traits
  belongs_to :harvest, inverse_of: :assoc_traits
  belongs_to :trait, inverse_of: :assoc_traits

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
