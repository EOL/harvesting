# An measurement formed by combining a "measurment or fact" with an "assoc", or by a column in the association file that
# is linked to a particular predicate.
class MetaAssoc < ActiveRecord::Base
  belongs_to :resource, inverse_of: :meta_assocs
  belongs_to :harvest, inverse_of: :meta_assocs
  belongs_to :assoc, inverse_of: :meta_assocs
  belongs_to :predicate_term, class_name: "Term"
  belongs_to :object_term, class_name: "Term"
  belongs_to :units_term, class_name: "Term"
  belongs_to :statistical_method_term, class_name: "Term"

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
