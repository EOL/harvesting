# A fact formed by combining one 'occurrence' with another 'occurrence'.
# NOTE: The name "association" is reserved in Rails.
class Assoc < ApplicationRecord
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

  # These are used during the CSV-writing stage of pre-publishing (copied from Trait)
  attr_accessor :sample_size, :citation, :source, :remarks, :method

  def metadata
    (meta_assocs + references + occurrence.occurrence_metadata).compact
  end

  def eol_pk
    "R#{resource_id}-PK#{id}"
  end

  def page_id
    node.page_id
  end

  def scientific_name
    node.scientific_name.italicized
  end

  def predicate
    eol_terms_uri(:predicate_term_uri)
  end

  def sex
    eol_terms_uri(:sex_term_uri)
  end

  def lifestage
    eol_terms_uri(:lifestage_term_uri)
  end

  def statistical_method
    nil
  end

  def object_page_id
    target_node.page_id
  end

  def target_scientific_name
    target_node.scientific_name.italicized
  end

  def value_uri
    nil
  end

  def literal
    nil
  end

  def measurement
    nil
  end

  def units
    nil
  end

  def normal_units_uri
    nil
  end

  def normal_measurement
    nil
  end

  def eol_terms_uri(method)
    uri = send(method)
    return nil if uri.blank?

    EolTerms.by_uri(uri)
  end
end
