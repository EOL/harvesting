class Resource < ApplicationRecord
  @logfile_name = 'process.log'
  @lockfile_name = 'harvest.lock'
  @unmatched_file_name = 'unmatched_nodes.txt'
  @media_download_batch_size = 32

  belongs_to :partner, inverse_of: :resources
  belongs_to :default_license, class_name: 'License', inverse_of: :resources

  has_many :formats, inverse_of: :resource, dependent: :destroy
  has_many :harvests, inverse_of: :resource, dependent: :destroy # NOTE: this destroy takes care of the rest.
  has_many :scientific_names, inverse_of: :resource
  has_many :nodes, inverse_of: :resource
  has_many :node_ancestors, inverse_of: :resource
  has_many :vernaculars, inverse_of: :resource
  has_many :media, inverse_of: :resource
  has_many :articles, inverse_of: :resource
  has_many :traits, inverse_of: :resource
  has_many :meta_traits, inverse_of: :resource
  has_many :assocs, inverse_of: :resource
  has_many :meta_assocs, inverse_of: :resource
  has_many :identifiers, inverse_of: :resource
  has_many :references, inverse_of: :resource
  has_many :harvest_processes, inverse_of: :resource, dependent: :destroy

  # TODO: oops, this should be HARVEST, not PUBLISH... NOTE that there is a call to resource.published! so search for
  # it. Also translations in en.yml
  enum publish_status: %i[unpublished publishing published deprecated updated_files harvest_pending removing_content]

  before_create :fix_abbr
  before_destroy :delete_trait_publish_files
  #after_save :propagate_to_publishing

  acts_as_list

  class << self
    attr_reader :logfile_name, :lockfile_name, :unmatched_file_name, :media_download_batch_size

    def native
      Rails.cache.fetch('resources/harvested_dynamic_hierarchy_1_1') do
        Resource.where(abbr: 'dvdtg').first_or_create do |r|
          r.name = 'EOL Dynamic Hierarchy 1.1'
          r.partner = nil
          r.description = ''
          r.abbr = 'dvdtg'
          r.is_browsable = true
          r.might_have_duplicate_taxa = false
          r.nodes_count = 650000
        end
      end
    end

    def quick_define(options)
      partner = if p_opts = options[:partner]
                  Partner.where(p_opts).first_or_create
                else
                  Partner.first
                end
      resource = where(name: options[:name]).first_or_create do |r|
        abbr = options[:abbr]
        abbr ||= options[:name].gsub(/[^A-Z]/, "")
        abbr ||= options[:name][0..3].upcase
        r.name = options[:name]
        r.pk_url = options[:pk_url] || "$PK"
        r.abbr = abbr
        r.partner_id = partner.id
      end
      pos = 1
      options[:formats].each do |rep, f_def|
        fmt = Format.where(
              field_sep: options[:field_sep] || ",",
              line_sep: options[:line_sep] || "\n",
              resource_id: resource.id,
              represents: rep).
            first_or_create do |f|
          f.resource_id = resource.id
          f.represents = rep
          f.file_type = Format.file_types[options[:type]]
          f.get_from = "#{options[:base_dir]}/#{f_def[:loc]}"
        end
        pos += 1
        field_pos = 1
        f_def[:fields].each do |field|
          Field.where(format_id: fmt.id, position: field_pos).first_or_create do |f|
            f.format_id = fmt.id
            f.position = field_pos
            f.expected_header = field.keys.first
            f.mapping = field.values.first
            f.submapping = field[:submapping]
            f.unique_in_format = field[:is_unique] || false
            f.can_be_empty = field.has_key?(:can_be_empty) ? field[:can_be_empty] : true
          end
          field_pos += 1
        end
      end
      resource
    end

    def from_xml(loc)
      Resource::FromMetaXml.by_path(loc)
    end

    def with_lock(resource_id)
      resource = Resource.find(resource_id)
      process = LoggedProcess.new(resource)
      resource.lock do
        begin
          yield(process)
        rescue Lockfile::TimeoutLockError => e
          process.fail(Exception.new('Already running!'))
          raise e
        rescue => e
          process.fail(e)
          raise e
        end
      end
    end

    def data_dir_path
      @data_dir_path ||= Rails.public_path.join('data')
    end

    # Exposed for tests, not to be used elsewhere
    def data_dir_path=(path)
      @data_dir_path = path
    end
  end

  def propagate_to_publishing
    WebDb.update_resource(self) # NOTE: this WILL create it, if missing.
  end

  def complete
    published!
    update_attributes(nodes_count: Node.where(resource_id: id).count, root_nodes_count: nodes.root.published.count)
  end

  def native?
    id == Resource.native.id?
  end

  def delayed_jobs
    if Delayed::Job.count > 100_000
      warning_message = '** SKIPPING delayed job operation, since there are too many delayed jobs (search would take too long).'
      Rails.logger.warn(warning_message)
      puts warning_message
      Delayed::Job.none
    else
      Delayed::Job.where(%Q{handler LIKE "%\\nresource_id: #{id}\\n%"})
    end
  end

  def stop_adding_media_jobs
    delayed_jobs.where(queue: 'media').delete_all
  end

  def undownloaded_media_count
    media.published.missing.count
  end

  def fix_downloaded_media_count
    missing = undownloaded_media_count
    update_attribute(:downloaded_media_count, media.count - missing)
    update_attribute(:failed_downloaded_media_count, missing)
  end

  def delayed_jobs
    Delayed::Job.where(queue: 'harvest').where("handler LIKE '%resource_id: #{id}%'")
  end

  def lockfile_name
    "#{path}/#{Resource.lockfile_name}"
  end

  # NOTE: why no #locked? ...Because it's not quite that simple. I didn't want to lull you into a false sense of the
  # resource being unlocked if you don't see a lockfile.
  def lockfile_exists?
    File.exist?(lockfile_name)
  end

  def unlock
    harvests.running.each { |h| h.fail }
    Rails.logger.info("Unlocking #{lockfile_name}")
    delayed_jobs.destroy_all
    if lockfile_exists?
      Lockfile.new(lockfile_name, timeout: 0.1).unlock
      Rails.logger.info("Unlocked.")
    else
      Rails.logger.info("No lockfile, proceed.")
    end
  rescue
    Rails.logger.warn("Failed to remove #{lockfile_name} politely, retrying manually.")
    File.unlink(lockfile_name) rescue nil
  end

  def lock
    if lockfile_exists?
      # TODO: Find a nice way to make this even more obvious. :\
      log_error('*****')
      log_error('***** HARVEST ATTEMPT FAILED: This resource is locked; assuming it is already running. '\
                'Remove lock if not.')
      log_error('*****')
      raise "Resource #{id} locked!"
    end
    lockfile = Lockfile.new(lockfile_name, timeout: 0.1)
    begin
      lockfile.lock
      yield
    ensure
      unlock
    end
  end

  def any_files_changed?
    return true if harvests.complete_non_failed.blank?

    last_harvest = harvests.complete_non_failed.last.created_at
    formats.each do |fmt|
      return true if File.mtime(fmt.get_from) > last_harvest
    end
    false
  end

  def publish_table_path(table, options = {})
    name = "publish_#{table}"
    name += "_#{options[:timestamp]}" if options[:timestamp]
    path.join("#{name}.tsv")
  end

  def path(make_if_missing = true)
    return @path if @path
    @path = self.class.data_dir_path.join(abbr.gsub(/\s+/, '_'))
    unless File.exist?(@path)
      if make_if_missing
        FileUtils.mkdir_p(@path)
      else
        raise "MISSING RESOURCE DIR (#{@path})!"
      end
    end
    @path
  end

  def process_log
    @log ||= create_process_log
  end

  # Requires a separate, callable command because after we clear it, we need to re-create it:
  def create_process_log
    ActiveSupport::TaggedLogging.new(Logger.new(process_log_path))
  end

  # Try not to use this. Use LoggedProcess instead. This is for "headless" jobs.
  def log_error(message)
    process_log.tagged('ERR') { process_log.warn("[#{Time.now.strftime('%F %T')}][hdls] #{message}") }
  end

  def process_log_path
    "#{path}/#{Resource.logfile_name}"
  end

  def unmatched_node_log_path
    "#{path}/#{Resource.unmatched_file_name}"
  end

  def move_files(to)
    formats.each { |fmt| fmt.update_attribute(:get_from, fmt.get_from.sub(%r{data/[^/]+/}, "data/#{to}/")) }
  end

  def re_read_xml
    Resource::FromMetaXml.new(self).create_models_from_xml
  end

  def re_download_opendata_and_harvest
    remove_content
    Resource::FromOpenData.reload(self)
    # TODO: Change this to something nicer, once we can handle deltas.
    harvest
  end

  def enqueue_harvest
    harvest_pending!
    Delayed::Job.enqueue(HarvestJob.new(id))
  end

  def enqueue_re_harvest
    harvest_pending!
    Delayed::Job.enqueue(ReHarvestJob.new(id))
  end

  def enqueue_resume_harvest
    harvest_pending!
    Delayed::Job.enqueue(ResumeHarvestJob.new(id))
  end

  def enqueue_re_download_opendata_harvest
    harvest_pending!
    Delayed::Job.enqueue(ReDownloadOpendataHarvestJob.new(id))
  end

  def harvest
    ResourceHarvester.new(self).start
  end

  def re_harvest
    harvests.destroy_all
    harvest
  end

  def publish
    Publisher.by_resource(self, LoggedProcess.new(self))
  end

  # This is meant to be called manually.
  def parse_names(names = nil)
    required_harvest = harvests.last
    raise 'Harvest the resource, first' if required_harvest.nil?
    if names.nil? || names.empty?
      NameParser.for_harvest(required_harvest, LoggedProcess.new(self))
    else
      NameParser.parse_names(required_harvest, names)
    end
  end

  def resume_instance
    @resume_instance ||= ResourceHarvester.new(self)
    @resume_instance.prep_resume
    @resume_instance
  end

  def resume
    resume_instance.start
  end

  def fake_partner
    return partner unless partner.nil?

    Partner.create(
      name: name || abbr.titleize,
      abbr: abbr.downcase,
      short_name: abbr.tr('_', ' '),
      homepage_url: "#{abbr}.com",
      description: 'This resource was auto-created by parsing meta.xml. A curator will edit this description shortly.',
      auto_publish: false
    )
  end

  def create_harvest_instance
    harvest = Harvest.create(resource_id: id)
    harvests << harvest
    harvest
  end

  def name_brief
    return @name_brief if @name_brief

    @name_brief = abbr.blank? ? name : abbr
    @name_brief.gsub(/[^a-z0-9\-]+/i, '_').sub(/_+$/, '').downcase
    @name_brief
  end

  # TODO: I'm not sure where this is called. (?)
  def remap_names(process)
    Resource::RemapNames.for_resource(self, process)
  end

  def download_missing_images
    return no_more_images_to_download if media.published.missing.count.zero?
    count = Medium.download_and_prep(media.published.missing.limit(Resource.media_download_batch_size))
    return no_more_images_to_download if count.zero?
    delay_more_downloads
  end

  def no_more_images_to_download
    msg = 'NO additional images were found to download'
    if media.published.failed_download.count.positive?
      msg += ', NOTE THAT SOME DOWNLOADS FAILED.'
    end
    log_error(msg)
    nil
  end

  def delay_more_downloads
    delay(queue: 'media').download_missing_images # NOTE: this *could* cause a kind of infinite loop...
  end

  # Because this happens often enough that it was worth making a method out of it. TODO: rename the @!#$*& fields:
  def swap_media_source_urls
    media.update_all('source_url=@tmp:=source_url, source_url=source_page_url, source_page_url=@tmp')
  end

  # NOTE: keeps formats, of course.
  def remove_content
    removing_content!
    # For some odd reason, the #delete_all on the association attempts to set resource_id: nil, which is wrong:
    [
      ScientificName, Vernacular, Article, Medium, Trait, MetaTrait, OccurrenceMetadatum, Assoc, MetaAssoc,
      Identifier, Reference
    ].each do |klass|
      remove_type(klass)
    end
    update_attribute(:downloaded_media_count, 0)
    update_attribute(:failed_downloaded_media_count, 0)
    update_attribute(:nodes_count, 0)
    update_attribute(:root_nodes_count, 0)
    remove_from_searchkick
    Searchkick.callbacks(false) do
      remove_type(Node)
    end
    remove_type_via_resource(NodeAncestor) # NOTE: This is BY FAR the longest step, still. Sigh.
    harvests.destroy_all
    delayed_jobs.delete_all
    unpublished!
  end

  def remove_from_searchkick
    nodes = get_searchkick_nodes
    while(nodes.count > 0)
      begin
        log_info("Starting batch with ID #{nodes.first.id}...")
        Node.searchkick_index.bulk_delete(nodes)
      rescue
        log_info('Failed! ...Sleeping for a moment...')
        sleep(60)
        log_info('Re-trying...')
        nodes.each do |node|
          begin
            Node.searchkick_index.bulk_delete([node]) # Using same method for consistency
          rescue => e
            raise "FAILED removing ElasticSearch index for Node #{node.id}: #{e.message}"
          end
        end
      ensure
        nodes = get_searchkick_nodes
      end
    end
  end

  def get_searchkick_nodes
    Node.search('*', where: { resource_id: id }, limit: 5000)
  end

  # NOTE: using harvest ids because everything is indexed on those:
  def remove_type(klass)
    log_info("## remove_type: #{klass}")
    total_count = klass.where(harvest_id: harvest_ids).count
    count = if total_count < 250_000
      log_info("++ Calling delete_all on #{total_count} instances...")
      klass.where(harvest_id: harvest_ids).delete_all
    else
      log_info("++ Batch removal of #{total_count} instances...")
      batch_size = 10_000
      times = 0
      expected_times = (total_count / batch_size)
      max_times = expected_times * 2 # No floating point math here, sloppiness okay.
      begin
        log_info("[#{Time.now.strftime('%H:%M:%S.%3N')}] Batch #{times}...")
        klass.connection.
          execute("DELETE FROM `#{klass.table_name}` WHERE harvest_id IN (#{harvest_ids.join(',')}) LIMIT #{batch_size}")
        Rails.logger.warn("Removed #{batch_size} out of #{total_count} rows from #{klass.table_name}. (#{times}/#{expected_times})")
        times += 1
        sleep(0.5) # Being (moderately) nice.
      end while klass.where(harvest_id: harvest_ids).count > 0 && times < max_times
      raise "Failed to delete all of the #{klass} instances! Tried #{times}x#{batch_size} times." if
        klass.where(harvest_id: harvest_ids).count.positive?
      total_count
    end
    str = "[#{Time.now.strftime('%H:%M:%S.%3N')}] Removed #{count} #{klass.name.humanize.pluralize}"
    log_info(str)
    str
  rescue => e # reports as Mysql2::Error but that doesn't catch it. :S
    log_info("There was an error, retrying: #{e.message}")
    sleep(2)
    Admin.maintain_db_connection(process_log)
    retry rescue "[#{Time.now.strftime('%H:%M:%S.%3N')}] UNABLE TO REMOVE #{klass.name.humanize.pluralize}: timed out"
  end

  def log_info(message)
    process_log.tagged('INFO') { process_log.warn("[#{Time.now.strftime('%F %T')}] #{message}") }
    process_log.flush
  end

  # This tends to be rather slow, so we do it in batches. TODO: I'd prefer a generic version of this logic live
  # somewhere else.
  def remove_type_via_resource(klass)
    min = klass.where(resource_id: id).minimum(:id)
    return if min.nil?
    max = klass.where(resource_id: id).maximum(:id)
    index = min
    batch_size = 10_000
    loop do
      klass.connection.execute("DELETE FROM `#{klass.table_name}` WHERE id >= #{index} AND "\
        "id < #{index + batch_size} AND resource_id = #{id}")
      index += batch_size
      break if index > max
    end
  end

  def delete_trait_publish_files
    Dir.glob(path.to_s + '/publish_traits*.tsv').each do |filename|
      File.unlink(filename)
    end
  end

  private
  def fix_abbr
    self.abbr.gsub!(/\s+/, '_') # No spaces allowed in this field! Ever!
    self.abbr.downcase! # No caps allowed in this field! Ever!
  end
end
