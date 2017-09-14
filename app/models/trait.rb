# An measurement formed by combining a "measurment or fact" with an "occurrence".
class Trait < ActiveRecord::Base
  belongs_to :resource, inverse_of: :traits
  belongs_to :harvest, inverse_of: :traits
  belongs_to :node, inverse_of: :traits
  belongs_to :object_node, class_name: "Node", inverse_of: :traits
  belongs_to :predicate_term, class_name: "Term"
  belongs_to :object_term, class_name: "Term"
  belongs_to :units_term, class_name: "Term"
  belongs_to :statistical_method_term, class_name: "Term"
  belongs_to :sex_term, class_name: "Term"
  belongs_to :lifestage_term, class_name: "Term"

  has_many :meta_traits, inverse_of: :trait

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
