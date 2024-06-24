# An measurement formed by combining a "measurment or fact" with an "association"
class AssocTrait < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :resource, inverse_of: :assoc_traits
  belongs_to :harvest, inverse_of: :assoc_traits
  belongs_to :trait, inverse_of: :assoc_traits

  scope :harvested, -> { where(removed_by_harvest_id: nil) }
end
