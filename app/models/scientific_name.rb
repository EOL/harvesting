class ScientificName < ActiveRecord::Base
  belongs_to :resource, inverse_of: :scientific_names
  belongs_to :node, inverse_of: :scientific_names
  belongs_to :dataset, inverse_of: :scientific_names

  has_many :nodes, inverse_of: :scientific_name
  has_many :scientific_names_references, inverse_of: :scientific_name
  has_many :references, through: :scientific_names_references

  # This list was captured from the document Katja produced (this link may not work for all):
  # https://docs.google.com/spreadsheets/d/1qgjUrFQQ8JHLtcVcZK7ClV3mlcZxxObjb5SXkr5FAUUqrr
  enum taxonomic_status: TaxonomicStatus.types

  scope :published, -> { where(removed_by_harvest_id: nil) }
  scope :used_for_merges, -> { where(is_used_for_merges: true) }

  def authors
    authorship.try(:split, '; ')
  end

  def attribution_html
    # dataset_id is just a field...
    # publication is a field... called "publisher" in her example...
    "Reference taxon: #{[scientific_name_link, according_to, via_statement].join(" ")}"
  end

  def scientific_name_link
    return normalized if node.further_information_url.blank?
    "<a href='#{node.further_information_url}'>#{normalized}</a>"
  end

  def according_to
    return nil if dataset.nil?
    "according to <a href='#{dataset.link}'>#{dataset.name}</a>"
  end

  def via_statement
    if dataset && !(dataset.publisher.blank? && dataset.supplier.blank?)
      return "via #{dataset.publisher}#{'/' if !dataset.publisher.blank? && !dataset.supplier.blank?}#{dataset.supplier}"
    end
    return nil if publication.blank?
    "via #{publication}"
  end
end
