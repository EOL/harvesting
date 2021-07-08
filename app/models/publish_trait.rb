class PublishTrait < ApplicationRecord
  belongs_to :resource
  belongs_to :harvest

  has_many :publish_metadata

  before_save :set_eol_pk

  class << self
    def from_trait(trait)
      self.new({
        resource_id: trait.resource_id,
        harvest_id: trait.harvest_id,
        page_id: trait.page_id,
        scientific_name: trait.scientific_name,
        resource_pk: trait.resource_pk,
        predicate_uri: trait.predicate,
        sex_uri: trait.sex,
        lifestage_uri: trait.lifestage,
        statistical_method_uri: trait.statistical_method,
        object_page_id: trait.object_page_id,
        target_scientific_name: trait.target_scientific_name,
        value_uri: trait.value_uri,
        literal: trait.literal,
        measurement: trait.measurement,
        units_uri: trait.units,
        normal_measurement: trait.normal_measurement,
        normal_units_uri: trait.normal_units_uri,
        sample_size: trait.sample_size,
        citation: trait.citation,
        source: trait.source,
        remarks: trait.remarks,
        method: trait.method,
        contributor_uri: trait.contributor_uri,
        compiler_uri: trait.compiler_uri,
        determined_by_uri: trait.determined_by_uri
      })
    end
  end

  def lifestage
    lifestage_uri
  end

  def statistical_method
    statistical_method_uri
  end

  def units
    units_uri
  end

  def predicate
    predicate_uri
  end

  def sex
    sex_uri
  end

  def set_eol_pk
    self.eol_pk = build_eol_pk
  end

  private
  def build_eol_pk
    meta_digests = publish_metadata.map { |m| m.digest }.sort
    attr_str = [
      resource_id,
      page_id,
      scientific_name,
      resource_pk,
      predicate_uri,
      sex_uri,
      lifestage_uri,
      statistical_method_uri,
      object_page_id,
      target_scientific_name,
      value_uri,
      literal,
      measurement,
      units_uri,
      normal_measurement,
      normal_units_uri,
      sample_size,
      citation,
      source,
      remarks,
      method,
      contributor_uri,
      compiler_uri,
      determined_by_uri,
    ].join('|')

    Digest::MD5.hexdigest({
      self_attrs: attr_str,
      meta_digests: meta_digests
    }.to_json)
  end
end

