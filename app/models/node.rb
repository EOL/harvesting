# A node in the hierarchy from a given content partner, including (most notably) its scientific name and the PK provided
# by the resource.
class Node < ApplicationRecord
  searchkick

  belongs_to :parent, class_name: 'Node', inverse_of: :children
  belongs_to :resource, inverse_of: :nodes
  belongs_to :harvest, inverse_of: :nodes
  belongs_to :scientific_name, inverse_of: :nodes

  has_many :scientific_names, inverse_of: :node, dependent: :delete_all
  has_many :articles, inverse_of: :node, dependent: :delete_all
  has_many :media, inverse_of: :node, dependent: :delete_all
  has_many :vernaculars, inverse_of: :node, dependent: :delete_all
  has_many :occurrences, inverse_of: :node, dependent: :delete_all
  has_many :traits, inverse_of: :node, dependent: :delete_all
  has_many :assocs, inverse_of: :node, dependent: :delete_all
  has_many :identifiers, inverse_of: :node, dependent: :delete_all
  has_many :nodes_references, inverse_of: :node, dependent: :delete_all
  has_many :references, through: :nodes_references
  has_many :node_ancestors, -> { order(:depth) }, inverse_of: :node, dependent: :delete_all
  has_many :descendants, class_name: 'NodeAncestor', inverse_of: :ancestor, foreign_key: :ancestor_id
  has_many :children, class_name: 'Node', foreign_key: :parent_id, inverse_of: :parent

  scope :root, -> { where('parent_id IS NULL') }
  scope :published, -> { where(removed_by_harvest_id: nil) }

  # NOTE: special scope used by Searchkick
  scope :search_import, -> {
    where('page_id IS NOT NULL').includes(:parent, :scientific_name, :scientific_names, :children, node_ancestors: :ancestor)
  }

  # Denotes the context in which the (non-zero) landmark ID should be used. Additional description:
  # https://github.com/EOL/eol_website/issues/5
  enum landmark: %i[no_landmark minimal abbreviated extended full]

  class << self
    def native_virus
      @native_virus ||= where(resource_id: Resource.native.id, canonical: 'Viruses') # Or we could look for page_id: 5006 ... but hey.
    end

    def remove_indexes(filter)
      Node.where(filter).find_each do |node|
        Node.searchkick_index.remove(node)
      end
    end

    def re_parse_ranks
      Node.update_all(rank: nil)
      while Node.where('rank IS NULL AND rank_verbatim IS NOT NULL').any? do
        batch = Node.where('rank IS NULL AND rank_verbatim IS NOT NULL').select('id, rank_verbatim').limit(2000)
        batch.map(&:rank_verbatim).uniq.each do |verbatim|
          Node.where(rank_verbatim: verbatim).update_all(rank: Rank.clean(verbatim))
        end
      end
    end
  end

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
      ancestor_page_ids: ancestor_page_ids,
      children: child_names,
      is_hybrid: scientific_name.try(:hybrid?),
      is_virus: scientific_name.try(:virus?),
      is_surrogate: scientific_name.try(:surrogate?),
      rank: rank,
      ancestor_ranks: ancestor_ranks
    }
  end

  def as_json(*)
    super(only: %i[page_id parent_resource_pk in_unmapped_area resource_pk landmark rank],
          methods: %i[scientific_name source_url ancestors],
          include: { identifiers: {}, scientific_name: { only: %i[normalized verbatim canonical] } })
  end

  def dump_eol_page_ids
    file = Rails.public_path.join('data', 'eol_page_ids.csv')
    CSV.open(file, 'wb', encoding: 'UTF-8') do |csv|
      where(resource_id: Resource.native.id).select('id, resource_pk, page_id').find_in_batches(batch_size: 25_000) do |batch|
        batch.each do |row|
          csv << [row.resource_pk, row.page_id]
        end
      end
    end
  end

  def ancestor_page_ids
    node_ancestors.map { |na| na&.ancestor&.page_id }.compact
  end

  def ancestor_ranks
    node_ancestors.map { |na| na&.ancestor&.rank }.compact
  end

  def title
    canonical.blank? ? "ID: #{resource_pk}" : canonical
  end

  def safe_canonical
    scientific_name&.canonical || "Unamed clade #{resource_pk}"
  end

  def safe_scientific
    scientific_name&.normalized || scientific_name&.verbatim || safe_canonical
  end

  def source_url
    resource.pk_url.gsub('$PK', CGI.escape(resource_pk))
  end

  def authors
    scientific_name.authors if scientific_name && scientific_name.is_used_for_merges?
  end

  def all_authors
    names = if scientific_names.loaded?
      scientific_names.select { |sn| sn.is_used_for_merges? }
    else
      scientific_names.used_for_merges
    end
    names.flat_map(&:authors) if scientific_names
  end

  def ancestors
    node_ancestors.map(&:ancestor_fk)
  end

  def needs_to_be_mapped?
    return true if page_id.blank?
    return true if page_id.zero?
    return true if in_unmapped_area?
    false
  end

  def child_names
    children.map(&:canonical)
  end

  def name # NOTE: just shorthand for common way of representing objects. Like #to_s...
    canonical
  end
end
