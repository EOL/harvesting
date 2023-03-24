class Harvest < ApplicationRecord
  belongs_to :resource, inverse_of: :harvests
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
    resource.enqueue_max_media_downloaders
  end

  def retry_failed_images
    resource.fix_downloaded_media_count
    bad_images = media.where(w: nil, format: Medium.formats[:jpg])
    return if bad_images.count.zero?
    bad_images.update_all(downloaded_at: nil)
    delay(queue: 'media').download_media
  end

  def convert_trait_units
    traits.where('measurement IS NOT NULL AND units_term_uri IS NOT NULL').find_each(&:convert_measurement)
  end

  # NOTE: if you are reading this looking for a way to reset a job that was killed, don't use this, use
  # @resourece.unlock
  def fail
    now = Time.now
    update_attributes(failed_at: now, completed_at: now)
  end

  def incomplete
    update_attributes(failed_at: nil, completed_at: nil)
  end
  
  def complete
    Admin.check_connection
    # NOTE: ScientificName goes straight to the model because the relationship goes through nodes.
    update_attributes(completed_at: Time.now,
                      nodes_count: nodes.count,
                      identifiers_count: identifiers.count,
                      scientific_names_count: ScientificName.where(harvest_id: id).count)
    update_attribute(:time_in_minutes, (completed_at - created_at).to_i / 60) if created_at
    resource.complete
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
    remove_files
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
      resource.unlock
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

  # NOTE: this does not remove the SOURCE files, only the intermediates we keep. :)
  def remove_files
    resource.formats.each do |fmt|
      converted_csv = converted_csv_path(fmt)
      File.unlink(converted_csv) if File.exist?(converted_csv)
      diff = diff_path(fmt)
      File.unlink(diff) if File.exist?(diff)
    end
  end

  def converted_csv_path(format)
    resource.format_path(format, 'converted_csv', 'csv')
  end

  def diff_size(format)
    file = diff_path(format) || format.get_from
    return 0 unless File.exist?(file)
    `wc -l #{file}`.chomp.split.first
  end

  def diff_parser(format)
    headers = nil
    headers = format.fields.map(&:expected_header) if format.data_begins_on_line&.positive?
    CsvParser.new(diff_path(format), headers: headers)
  end

  def diff_path(format)
    resource.format_path(format, 'diff', 'diff')
  end

  def trait_filename
    options = {}
    options[:timestamp] = self.created_at.to_i if resource.can_perform_trait_diffs?
    resource.publish_table_path('traits', options)
  end

private

end
