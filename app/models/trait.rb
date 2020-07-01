# An measurement formed by combining a 'measurment or fact' with an 'occurrence'.
class Trait < ApplicationRecord
  # These are used during the CSV-writing stage of pre-publishing:
  attr_accessor :sample_size, :citation, :source, :remarks, :method

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
  belongs_to :occurrence, inverse_of: 'traits'

  has_many :meta_traits, inverse_of: :trait
  has_many :children, class_name: 'Trait', inverse_of: :parent, foreign_key: 'parent_id'
  has_many :traits_references, inverse_of: :trait
  has_many :references, through: :traits_references

  scope :published, -> { where(removed_by_harvest_id: nil) }
  scope :primary, -> { where(of_taxon: true) }
  scope :matched, -> { where('node_id IS NOT NULL') }
  scope :unmatched, -> { where('node_id IS NULL') }

  def metadata
    (meta_traits + references + children + occurrence.occurrence_metadata).compact
  end

  # NOTE: yes, it makes me nervous that we're pegging the EOL identifier on the harvesting DB ID. In theory, this should
  # be the PK from the partner. But after discussing things with Jen, we determined that data will ALWAYS be nuked and
  # re-created for a resource, because the PK cannot ever actually be trusted. No "updates" are available for data, only
  # complete re-ingestion. So using an ID here keeps the PK succinct (it's all integers) and much shorter (some PKs can
  # be very, very long):
  def eol_pk
    "R#{resource_id}-PK#{id}"
  end

  # NOTE: this is NOT called by the code (it's meant for debugging at the prompt), and it's out of place (usually 'self'
  # methods are put at the top) because I wanted it to be paired with and appear after the #eol_pk method, upon which it
  # is strongly coupled.
  def self.find_by_eol_pk(key)
    rid, pk = key.match(/^R(\d+)-PK(.*)$/).captures
    where(resource_id: rid, id: pk).first
  end

  def page_id
    node.page_id
  end

  def scientific_name
    node.scientific_name.italicized
  end

  def predicate
    predicate_term.uri
  end

  def sex
    sex_term&.uri
  end

  def lifestage
    lifestage_term&.uri
  end

  def statistical_method
    statistical_method_term&.uri
  end

  def object_page_id
    nil
  end

  def target_scientific_name
    nil
  end

  def value_uri
    object_term&.uri
  end

  def units
    units_term&.uri
  end

  def convert_measurement
    return unless measurement
    num = measurement_to_num
    if num.is_a?(Numeric) && units_term && !units_term.uri.blank?
      (n_val, n_unit) = UnitConversions.convert(num, units_term.uri)
      update_attributes(normal_measurement: n_val, normal_units_uri: n_unit)
    elsif units_term && !units_term.uri.blank?
      update_attributes(normal_measurement: num, normal_units_uri: units_term.uri)
    else
      update_attributes(normal_measurement: num, normal_units_uri: '')
    end
    save
  end

  def measurement_to_num
    Integer(measurement)
  rescue ArgumentError, TypeError
    begin
      Float(measurement)
    rescue ArgumentError, TypeError
      measurement
    end
  end
end
