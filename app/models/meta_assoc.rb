# An measurement formed by combining a "measurment or fact" with an "assoc", or by a column in the association file that
# is linked to a particular predicate.
class MetaAssoc < ApplicationRecord
  belongs_to :resource, inverse_of: :meta_assocs
  belongs_to :harvest, inverse_of: :meta_assocs
  belongs_to :assoc, inverse_of: :meta_assocs

  scope :harvested, -> { where(removed_by_harvest_id: nil) }
end
