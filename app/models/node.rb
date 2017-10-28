# A node in the hierarchy from a given content partner, including (most notably) its scientific name and the PK provided
# by the resource.
class Node < ActiveRecord::Base
  searchkick

  belongs_to :parent, class_name: 'Node', inverse_of: :children
  belongs_to :resource, inverse_of: :nodes
  belongs_to :harvest, inverse_of: :nodes
  belongs_to :scientific_name, inverse_of: :nodes

  has_many :scientific_names, inverse_of: :node, dependent: :destroy
  has_many :media, inverse_of: :node, dependent: :destroy
  has_many :vernaculars, inverse_of: :node, dependent: :destroy
  has_many :occurrences, inverse_of: :node
  has_many :traits, inverse_of: :node
  has_many :identifiers, inverse_of: :node
  has_many :nodes_references, inverse_of: :node
  has_many :references, through: :nodes_references
  has_many :node_ancestors, inverse_of: :node
  has_many :descendants, class_name: 'NodeAncestor', inverse_of: :ancestor, foreign_key: :ancestor_id
  has_many :ancestors, through: :node_ancestors
  has_many :children, class_name: 'Node', foreign_key: :parent_id, inverse_of: :parent

  scope :root, -> { where('parent_id IS NULL') }
  scope :published, -> { where(removed_by_harvest_id: nil) }

  # NOTE: special scope used by Searchkick
  scope :search_import, -> {
    where('page_id IS NOT NULL').includes(:parent, :scientific_name, :scientific_names, :children)
  }

  # Denotes the context in which the (non-zero) landmark ID should be used. Additional description:
  # https://github.com/EOL/eol_website/issues/5
  enum landmark: %i[minimal abbreviated extended full]

  # NOTE: special method used by Searchkick
  def search_data
    {
      id: id,
      resource_id: resource_id,
      page_id: page_id,
      authors: authors,
      synonyms: scientific_names.map(&:canonical),
      synonym_authors: all_authors,
      canonical: canonical,
      ancestor_page_ids: ancestors.map(&:page_id).compact,
      children: child_names,
      is_hybrid: scientific_name.try(:hybrid?),
      is_virus: scientific_name.try(:virus?),
      is_surrogate: scientific_name.try(:surrogate?)
    }
  end

  def self.native_virus
    @native_virus ||= where(resource_id: 1, canonical: 'Viruses') # Or we could look for page_id: 5006 ... but hey.
  end

  def authors
    scientific_name.authors if scientific_name && scientific_name.is_used_for_merges?
  end

  def all_authors
    scientific_names.used_for_merges.flat_map(&:authors) if scientific_names
  end

  def needs_to_be_mapped?
    return true if page_id.blank?
    return false if resource_id == 1 # NOTE: hard-coded DWH as 1. It really needs to be first.
    return true if in_unmapped_area?
    # TODO: This won't actually happen; add these cases natively to the harvester (set the page_id to nil).
    # TODO: Think about what would happen if DWH changed Animalia and was reharvested. Does EVERYTHING get re-matched?
    return true if scientific_name.changed?
  end

  def child_names
    children.map(&:canonical)
  end

  def name # NOTE: just shorthand for common way of representing objects. Like #to_s...
    canonical
  end
end
