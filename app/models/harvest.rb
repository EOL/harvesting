class Harvest < ActiveRecord::Base
  belongs_to :resource, inverse_of: :harvests
  has_many :formats, inverse_of: :harvest # NOTE: see #remove_content...
  has_many :hlogs, inverse_of: :harvest # destroyed via formats
  has_many :nodes, inverse_of: :harvest # NOTE: see #remove_content...
  has_many :scientific_names, through: :nodes, source: 'scientific_names'
  has_many :occurrences, inverse_of: :harvest # destroyed via nodes
  has_many :occurrence_metadata, inverse_of: :harvest, dependent: :delete_all
  has_many :traits, inverse_of: :harvest # destroyed via nodes
  has_many :meta_traits, inverse_of: :harvest, dependent: :delete_all
  has_many :assocs, inverse_of: :harvest # destroyed via nodes
  has_many :meta_assocs, inverse_of: :harvest, dependent: :delete_all
  has_many :assocs_references, inverse_of: :harvest, dependent: :delete_all
  has_many :assoc_traits, inverse_of: :harvest, dependent: :delete_all
  has_many :identifiers, inverse_of: :harvest # destroyed via nodes
  has_many :media, inverse_of: :harvest # destroyed via nodes
  has_many :articles, inverse_of: :harvest # destroyed via nodes
  has_many :vernaculars, inverse_of: :harvest # destroyed via nodes

  before_destroy :remove_content

  delegate :resume, to: :resource

  scope :complete_non_failed, -> { where('completed_at IS NOT NULL AND failed_at IS NULL') }
  scope :failed, -> { where('failed_at IS NOT NULL') }
  scope :running, -> { where('failed_at IS NULL AND completed_at IS NULL') }

  # NOTE: BE **VERY** careful, here: these are the methods used in ResourceHarvester. It made more sense to me to keep
  # the list here (because it's database-dependent), but really, if you change the methods there, you MUST do something
  # about these, probably involving a complex migration of bumping the integer values in the DB to insert the new name
  # or remove an old one....
  #
  # HINT: Choose the NEXT stage you want to run, NOT the one that's completed. This is the CURRENT stage, and is
  # INCOMPLETE.
  enum stage: %i[
    create_harvest_instance fetch_files validate_each_file convert_to_csv calculate_delta parse_diff_and_store
    resolve_keys hold_for_later_1 hold_for_later_2 resolve_missing_parents rebuild_nodes
    resolve_missing_media_owners sanitize_media_verbatims queue_downloads parse_names
    denormalize_canonical_names_to_nodes match_nodes reindex_search normalize_units calculate_statistics
    complete_harvest_instance completed
  ]

  def download_media
    if media.needs_download.count.zero?
      resource.fix_downloaded_media_count
      return
    end
    Medium.download_and_prep(media.needs_download.limit(25))
    delay(queue: 'media').download_media
  end

  def retry_failed_images
    resource.fix_downloaded_media_count
    bad_images = media.where(w: nil, format: Medium.formats[:jpg])
    return if bad_images.count.zero?
    bad_images.update_all(downloaded_at: nil)
    delay(queue: 'media').download_media
  end

  def convert_trait_units
    traits.where('measurement IS NOT NULL AND units_term_id IS NOT NULL').find_each(&:convert_measurement)
  end

  def fail
    now = Time.now
    update_attributes(failed_at: now, completed_at: now)
  end

  def incomplete
    update_attributes(failed_at: nil, completed_at: nil)
  end

  # TODO: these two methods are obsolete. Remove them and their calls.
  def started_matching_at
    hlogs.where(category: Hlog.categories[:starts]).where('message LIKE "%match_nodes"')&.first&.created_at
  end

  def finished_matching_at
    hlogs.where(category: Hlog.categories[:starts]).where('message LIKE "%reindex_search"')&.first&.created_at
  end

  def complete
    update_attribute(:completed_at, Time.now)
    update_attribute(:time_in_minutes, (completed_at - created_at).to_i / 60)
    resource.published!
    resource.update_attribute(:nodes_count, Node.where(resource_id: id).count)
  end

  def remove_content
    # Because node.destroy does all of this work but MUCH less efficiently, we fake it all here:
    [ScientificName, Medium, Article, Vernacular, Occurrence, Trait, Assoc, Identifier, NodesReference,
     Reference, ContentAttribution, Attribution].each do |klass|
       count = klass.where(harvest_id: id).count
       # puts "#{klass}: #{count}"
       next if count.zero?
       klass.connection.execute("DELETE FROM `#{klass.table_name}` WHERE harvest_id = #{id}")
       # puts "#{klass}: #{klass.where(harvest_id: id).count}"
     end
    formats.each(&:remove_content)
    # NOTE: halved the size of these batches in Apr 2019 because of timeouts.
    nodes.pluck(:id).in_groups_of(2500, false) do |batch|
      remove_ancestors_natively(batch)
      Node.remove_indexes(id: batch)
      Searchkick.callbacks(false) do
        remove_nodes_natively(batch)
      end
    end
    update_attribute(:completed_at, Time.now) unless completed_at
    begin
      resource.rm_lockfile
    rescue => e
      puts "WARNING (non-fatal): #{e.message}"
    end
  end

  def remove_ancestors_natively(node_ids)
    NodeAncestor.connection.execute("DELETE FROM node_ancestors WHERE node_id IN (#{node_ids.join(',')})")
  end

  def remove_nodes_natively(node_ids)
    Node.connection.execute("DELETE FROM nodes WHERE id IN (#{node_ids.join(',')})")
  end
end
