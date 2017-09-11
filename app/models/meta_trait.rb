# An measurement formed by combining a "measurment or fact" with an "occurrence".
class MetaTrait < ActiveRecord::Base
  belongs_to :resource, inverse_of: :meta_traits
  belongs_to :harvest, inverse_of: :meta_traits
  belongs_to :trait, inverse_of: :meta_traits

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
