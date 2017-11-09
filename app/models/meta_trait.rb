# An measurement formed EITHER by combining a "measurment or fact" with an "occurrence" OR by a column in the
# "measurment or fact" file that is linked to a particular predicate.
class MetaTrait < ActiveRecord::Base
  belongs_to :resource, inverse_of: :meta_traits
  belongs_to :harvest, inverse_of: :meta_traits
  belongs_to :trait, inverse_of: :meta_traits
  belongs_to :predicate_term, class_name: "Term"
  belongs_to :object_term, class_name: "Term"
  belongs_to :units_term, class_name: "Term"
  belongs_to :statistical_method_term, class_name: "Term"

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
