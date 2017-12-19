# A fact formed by combining one 'occurrence' with another 'occurrence'.
# NOTE: The name "association" is reserved in Rails.
class Assoc < ActiveRecord::Base
  belongs_to :resource, inverse_of: :assocs
  belongs_to :harvest, inverse_of: :assocs
  belongs_to :node, inverse_of: :assocs
  belongs_to :target_node, class_name: 'Node'
  belongs_to :predicate_term, class_name: 'Term'
  belongs_to :occurrence, inverse_of: 'assocs'
  belongs_to :target_occurrence
  belongs_to :sex_term, class_name: 'Term'
  belongs_to :lifestage_term, class_name: 'Term'

  has_many :meta_assocs, inverse_of: :assoc
  has_many :assocs_references, inverse_of: :assoc
  has_many :references, through: :assocs_references

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
