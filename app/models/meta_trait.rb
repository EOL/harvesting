# An measurement formed EITHER by combining a "measurment or fact" with an "occurrence" OR by a column in the
# "measurment or fact" file that is linked to a particular predicate.
class MetaTrait < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :resource, inverse_of: :meta_traits
  belongs_to :harvest, inverse_of: :meta_traits
  belongs_to :trait, inverse_of: :meta_traits

  scope :harvested, -> { where(removed_by_harvest_id: nil) }
end
