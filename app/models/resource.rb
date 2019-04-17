class Resource < ActiveRecord::Base
  belongs_to :partner, inverse_of: :resources
  belongs_to :default_license, class_name: 'License', inverse_of: :resources

  has_many :formats, inverse_of: :resource, dependent: :destroy
  has_many :harvests, inverse_of: :resource, dependent: :destroy # NOTE: this destroy takes care of the rest.
  has_many :scientific_names, inverse_of: :resource
  has_many :nodes, inverse_of: :resource
  has_many :vernaculars, inverse_of: :resource
  has_many :media, inverse_of: :resource
  has_many :articles, inverse_of: :resource
  has_many :traits, inverse_of: :resource
  has_many :meta_traits, inverse_of: :resource
  has_many :assocs, inverse_of: :resource
  has_many :meta_assocs, inverse_of: :resource
  has_many :identifiers, inverse_of: :resource
  has_many :references, inverse_of: :resource

  # TODO: oops, this should be HARVEST, not PUBLISH... NOTE that there is a call to resource.published! so search for
  # it. Also translations in en.yml
  enum publish_status: %i[unpublished publishing published deprecated updated_files harvest_pending removing_content]

  acts_as_list

  def self.quick_define(options)
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
          abstract.
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

  def self.from_xml(loc, resource = nil)
    abbr = File.basename(loc)
    # NOTE: the type is :csv because we don't have XML defining an Excel spreadsheet.
    resource ||= create(name: abbr.titleize, abbr: abbr.downcase, pk_url: '$PK')
    resource.partner = resource.fake_partner
    resource.save
    Resource::FromMetaXml.import(loc, resource)
    resource
  end

  def stop_adding_media_jobs
    Delayed::Job.where(queue: 'media').where(%(handler LIKE "%resource_id: #{id}%")).delete_all
  end

  def undownloaded_media_count
    media.where(sizes: nil).count
  end

  def fix_downloaded_media_count
    update_attribute(:downloaded_media_count, media.where('sizes IS NOT NULL').count)
  end

  def lockfile_name
    "#{path}/harvest.lock"
  end

  # NOTE: why no #locked? ...Because it's not quite that simple. I didn't want to lull you into a false sense of the
  # resource being unlocked if you don't see a lockfile.
  def lockfile_exists?
    File.exist?(lockfile_name)
  end

  def rm_lockfile
    File.unlink(lockfile_name) if lockfile_exists?
  end

  def lock
    raise "Resource #{id} locked!" if lockfile_exists?
    lockfile = Lockfile.new(lockfile_name, timeout: 0.01)
    begin
      lockfile.lock
      yield
    ensure
      lockfile.unlock
      rm_lockfile
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

  def publish_table_path(table)
    path.join("publish_#{table}.tsv")
  end

  def path(make_if_missing = false)
    return @path if @path
    @path = Rails.public_path.join('data', abbr.gsub(/\s+/, '_'))
    unless File.exist?(@path)
      if make_if_missing
        FileUtils.mkdir_p(@path)
      else
        raise "MISSING RESOURCE DIR (#{@path})!"
      end
    end
    @path
  end

  def move_files(to)
    formats.each { |fmt| fmt.update_attribute(:get_from, fmt.get_from.sub(%r{data/[^/]+/}, "data/#{to}/")) }
  end

  def re_read_xml
    where = formats.any? ? File.dirname(formats.first.get_from) : path
    Resource.from_xml(where, self)
  end

  def re_download_opendata_and_harvest
    harvests.destroy_all
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
    Publisher.by_resource(self)
  end

  def parse_names
    required_harvest = harvests.last
    raise 'Harvest the resource, fisrt' if required_harvest.nil?
    harvest.log('Resource requested #parse_names (directly)', cat: :starts)
    NameParser.for_harvest(required_harvest)
    harvest.log('Resource completed direct #parse_names', cat: :ends)
    required_harvest.complete!
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
    formats.abstract.each { |fmt| fmt.copy_to_harvest(harvest) }
    harvest
  end

  def name_brief
    return @name_brief if @name_brief
    @name_brief = abbr.blank? ? name : abbr
    @name_brief.gsub(/[^a-z0-9\-]+/i, '_').sub(/_+$/, '').downcase
    @name_brief
  end

  def start_harvest
    harvester = ResourceHarvester.new(self)
    harvester.start
    harvester
  end

  def remap_names
    Resource::RemapNames.for_resource(self)
  end

  def download_missing_images
    return no_more_images_to_download if media.published.missing.count.zero?
    count = Medium.download_and_prep(media.published.missing.limit(25))
    return no_more_images_to_download if count.zero?
    delay_more_downloads
  end

  def no_more_images_to_download
    msg = 'NO additional images were found to download'
    if media.published.failed_download.count.positive?
      msg += ', NOTE THAT SOME DOWNLOADS FAILED.'
    end
    harvests.last.log(msg, cat: :warns)
    nil
  end

  def delay_more_downloads
    delay(queue: 'media').download_missing_images # NOTE: this *could* cause a kind of infinite loop...
  end

  def convert_trait_units
    traits.where('measurement IS NOT NULL AND units_term_id IS NOT NULL').find_each(&:convert_measurement)
  end

  # Because this happens often enough that it was worth making a method out of it. TODO: rename the @!#$*& fields:
  def swap_media_source_urls
    media.update_all('source_url=@tmp:=source_url, source_url=source_page_url, source_page_url=@tmp')
  end

  # NOTE: keeps formats, of course.
  def remove_content
    removing_content!
    harvests.each { |h| h.destroy }
    # For some odd reason, the #delete_all on the association attempts to set resource_id: nil, which is wrong:
    ScientificName.where(resource_id: id).delete_all
    Vernacular.where(resource_id: id).delete_all
    Article.where(resource_id: id).delete_all
    Medium.where(resource_id: id).delete_all
    Trait.where(resource_id: id).delete_all
    MetaTrait.where(resource_id: id).delete_all
    OccurrenceMetadatum.where(resource_id: id).delete_all
    Assoc.where(resource_id: id).delete_all
    MetaAssoc.where(resource_id: id).delete_all
    Identifier.where(resource_id: id).delete_all
    Reference.where(resource_id: id).delete_all
    Node.remove_indexes(resource_id: id)
    Node.where(resource_id: id).delete_all
    NodeAncestor.where(resource_id: id).delete_all
    if Delayed::Job.count > 100_000
      puts '** SKIPPING delayed job clear, since there are too many delayed jobs.'
    else
      Delayed::Job.where("handler LIKE '%resource_id: #{id}%'").delete_all
    end
    unpublished!
  end
end
