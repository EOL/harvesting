class Node < ActiveRecord::Base
  belongs_to :resource, inverse_of: :nodes
  belongs_to :harvest, inverse_of: :nodes
  # TODO belongs_to :page, inverse_of: :nodes
  belongs_to :parent, class_name: "Node", inverse_of: :children
  belongs_to :scientific_name, inverse_of: :nodes

  has_many :scientific_names, inverse_of: :node, dependent: :destroy
  has_many :media, inverse_of: :node
  has_many :children, class_name: "Node", inverse_of: :parent,
    foreign_key: "parent_id"
  has_many :vernaculars, inverse_of: :node
  has_many :occurrences, inverse_of: :node
  has_many :traits, inverse_of: :node

  scope :root, -> { where(parent_id: 0) }
  scope :published, -> { where(removed_by_harvest_id: nil) }

  # TODO: probably move all of this to the Page class.

  # NOTE: special scope used by Searchkick
  # TODO: add the page with all of its nodes and their scientific names and vernaculars
  scope :search_import, -> { includes(:parent, :scientific_name, :scientific_names, :children) }

  # NOTE: special method used by Searchkick
  def search_data
    # TODO: all of the maps for scientific_names should ONLY use names that are "is_used_for_merges"
    {
      id: id,
      resource_id: resource_id,
      page_id: page_id,
      authors: scientific_name.authors,
      synonyms: scientific_names.map(&:canonical),
      synonym_authors: scientific_names.flat_map { |sn| sn.authors },
      canonical: canonical,
      ancestor_ids: ancestors.map(&:id),
      children: children.map(&:canonical),
      is_hybrid: scientific_name.hybrid?,
      is_virus: scientific_name.virus?,
      is_surrogate: scientific_name.surrogate?
    }
  end

  def needs_to_be_mapped?
    return true if page_id.blank?
    return true if in_unmapped_area?
    # TODO: This won't actually happen; add these cases natively to the harvester (set the page_id to nil).
    # TODO: Think about what would happen if DWH changed Animalia and was reharvested. Does EVERYTHING get re-matched?
    return true if scientific_name.changed?
  end

  def matched_ancestor(depth)
    i = 0
    ancestors.each do |ancestor|
      unless ancestor.page_id.nil?
        return ancestor if i >= depth
        i += 1
      end
    end
  end
end
