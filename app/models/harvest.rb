class Harvest < ActiveRecord::Base
  belongs_to :resource, inverse_of: :harvests
  has_many :formats, inverse_of: :harvest, dependent: :destroy # NOTE: a few more deletes off of this one.
  has_many :hlogs, inverse_of: :harvest # destroyed via formats
  has_many :nodes, inverse_of: :harvest, dependent: :destroy # NOTE: a lot of dependent deletes from this one.
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

  delegate :resume, to: :resource

  # NOTE: Be careful. #completed is this scope, #completed! sets the stage to completed, and completed? checks that the
  # stage is "completed"...
  scope :completed, -> { where("completed_at IS NOT NULL") }

  # NOTE: BE **VERY** careful, here: these are the methods used in ResourceHarvester. It made more sense to me to keep
  # the list here (because it's database-dependent), but really, if you change the methods there, you MUST do something
  # about these, probably involving a complex migration of bumping the integer values in the DB to insert the new name
  # or remove an old one....
  #
  # HINT: Choose the NEXT stage you want to run, NOT the one that's completed. This is the CURRENT stage, and is
  # INCOMPLETE.
  enum stage: %i[
    create_harvest_instance fetch_files validate_each_file convert_to_csv calculate_delta parse_diff_and_store
    resolve_node_keys resolve_media_keys resolve_trait_keys resolve_missing_parents rebuild_nodes
    resolve_missing_media_owners sanitize_media_verbatims queue_downloads parse_names
    denormalize_canonical_names_to_nodes match_nodes reindex_search normalize_units calculate_statistics
    complete_harvest_instance completed
  ]

  def download_all_images
    media.where(format: Medium.formats[:jpg], downloaded_at: nil).find_each { |med| med.delay.download_and_resize }
  end

  def complete
    update_attribute(:completed_at, Time.now)
    update_attribute(:time_in_minutes, (completed_at - created_at).to_i / 60)
    resource.published!
    resource.update_attribute(:nodes_count, Node.where(resource_id: id).count)
  end

  def log_call
    i = caller.index { |c| c =~ /harvester/ } # TODO: really, we don't KNOW that's the name. :S
    (file, method) = caller(i+1..i+1).first.split
    log("#{file.split('/').last.split(':')[0..1].join(':')}##{method[1..-2]}", cat: :starts)
  rescue
    log("Starting method #{caller(0..0)}")
  end

  # Reminder: errors warns infos progs loops starts ends counts queries commands names_matches
  def log(message, options = {})
    options[:cat] ||= :infos
    trace = options[:e] ? options[:e].backtrace&.join("\n") || options[:e].class : nil
    hash = {
      harvest: self,
      category: options[:cat],
      message: message[0..65_534], # Truncates really long messages, alas...
      backtrace: trace,
      line: options[:line]
    }
    # TODO: we should be able to configure whether this outputs to STDOUT:
    puts "[#{Time.now.strftime('%H:%M:%S.%3N')}](#{options[:cat]}) #{message}"
    STDOUT.flush
    hlogs << Hlog.create!(hash.merge(format: options[:format]))
  end
end
