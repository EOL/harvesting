# An measurement formed by combining a 'measurment or fact' with an 'occurrence'.
class Trait < ActiveRecord::Base
  belongs_to :parent, inverse_of: :children, class_name: 'Trait', foreign_key: 'parent_id'
  belongs_to :resource, inverse_of: :traits
  belongs_to :harvest, inverse_of: :traits
  belongs_to :node, inverse_of: :traits
  belongs_to :object_node, class_name: 'Node', inverse_of: :traits
  belongs_to :predicate_term, class_name: 'Term'
  belongs_to :object_term, class_name: 'Term'
  belongs_to :units_term, class_name: 'Term'
  belongs_to :statistical_method_term, class_name: 'Term'
  belongs_to :sex_term, class_name: 'Term'
  belongs_to :lifestage_term, class_name: 'Term'
  belongs_to :occurrence, foreign_key: 'occurrence_resource_pk', primary_key: 'resource_pk', inverse_of: 'traits'

  has_many :meta_traits, inverse_of: :trait
  has_many :children, class_name: 'Trait', inverse_of: :parent, foreign_key: 'parent_id'
  has_many :traits_references, inverse_of: :trait
  has_many :references, through: :traits_references

  scope :published, -> { where(removed_by_harvest_id: nil) }
  scope :primary, -> { where(of_taxon: true) }
  scope :matched, -> { where('node_id IS NOT NULL') }
end
