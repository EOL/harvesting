class Medium < ActiveRecord::Base
  belongs_to :resource, inverse_of: :media
  belongs_to :harvest, inverse_of: :media
  belongs_to :node, inverse_of: :media
  belongs_to :license, inverse_of: :media
  belongs_to :language
  belongs_to :location, inverse_of: :media
  belongs_to :bibliographic_citation

  has_many :media_references, inverse_of: :medium
  has_many :references, through: :media_references

  has_many :content_attributions, as: :content
  has_many :attributions, through: :content_attributions

  # NOTE: these MUST be kept in sync with the eol_website codebase! Be careful. Sorry for the conflation.
  enum subclass: %i[image video sound map_image js_map]
  enum format: %i[jpg youtube flash vimeo mp3 ogg wav mp4 ogv mov svg webm]

  scope :published, -> { where(removed_by_harvest_id: nil) }
  scope :missing, -> { where(format: Medium.formats[:jpg], downloaded_at: nil) }
  scope :failed_download, -> { where(format: Medium.formats[:jpg], sizes: nil).where('downloaded_at IS NOT NULL') }

  class << self
    attr_accessor :sizes, :bucket_size

    # NOTE: this is TEMP code for use ONCE. You can delete it, if you are reading this. Yes, really. Truly. Do it.
    def fix_wikimedia_characters(res)
      res.media.where(w: nil).find_each do |img|
        next if img.source_url =~ /(svg|ogg|ogv)$/
        string = img.source_page_url.sub(/^.*File:/, '').sub(/\..{3,4}$/, '')
        good_name = URI.decode(string)
        bad_name = img.source_url.sub(/^.*\//, '').sub(/\..{3,4}$/, '')
        %i[source_url name_verbatim name description description_verbatim].each do |f|
          img[f].sub!(bad_name, good_name) unless img[f].nil?
        end
        img.save
        img.download_and_prep
      end
    end

    def download_and_prep(images)
      count = 0
      images.select('id').map(&:id).each do |img_id|
        next if download_enqueued?(img_id)
        Delayed::Job.enqueue(DownloadMediumJob.new(img_id))
        count += 1
      end
      count
    end

    def download_enqueued?(id)
      Delayed::Job.where(queue: 'media').where(%(handler LIKE "%DownloadMediumJob%medium_id: #{id}%")).any?
    end
  end

  @sizes = %w[88x88 98x68 580x360 130x130 260x190]
  @bucket_size = 256

  def s_dir
    dir_from_mod(id)
  end

  def m_num
    id / Medium.bucket_size
  end

  def m_dir
    dir_from_mod(m_num)
  end

  def l_num
    m_num / Medium.bucket_size
  end

  def l_dir
    dir_from_mod(l_num)
  end

  def dir
    Rails.public_path.join(path)
  end

  def path
    "data/media/#{l_dir}/#{m_dir}/#{s_dir}"
  end

  def dir_from_mod(mod)
    '%02x' % (mod % Medium.bucket_size)
  end

  def default_base_url
    "#{path}/#{basename}"
  end

  def basename
    "#{resource_id}.#{resource_pk&.tr('^-_A-Za-z0-9', '_')}"
  end

  def ensure_dir_exists
    unless Dir.exist?(dir)
      FileUtils.mkdir_p(dir)
      FileUtils.chmod(0o755, dir)
    end
  end

  def sanitized_source_url
    @sanitized_source_url ||= source_url.sub(/^https/, 'http')
  end

  def fix_encoding_for_sanitized_source_url
    extend EncodingFixer
    bad_url = sanitized_source_url
    @sanitized_source_url = fix_encoding(sanitized_source_url)
    raise "Unable to resolve URL #{sanitized_source_url}" if bad_url == sanitized_source_url
  end

  def download_and_prep
    begin
      ensure_dir_exists
      abort_if_filetype_unreadable
      raw = download_raw_data
      # TODO: This is where we need to branch out and handle other media types...
      prepper = get_prepper(raw)
      raw = nil # Ensure it's not taking up memory anymore (well, modulo GC). It c/b quite large!
      prepper.prep_medium
    rescue => e
      return fail_from_download_and_prep(e)
    end
  end

  def fail_from_download_and_prep(e)
    update_attribute(:downloaded_at, Time.now) # Avoid attempting it again...
    resource.update_attribute(:failed_downloaded_media_count, resource.failed_downloaded_media_count + 1)
    harvest.log("download_and_prep FAILED for Medium.find(#{self[:id]}) [#{e.backtrace.first}]: #{e.message[0..1000]}",
      cat: :downloads)
    nil
  end

  def safe_name
    name.blank? ? "#{subclass.titleize} of #{node.canonical}" : name
  end

  def download_raw_data
    require 'open-uri'
    uri = URI.parse(URI.encode(sanitized_source_url))
    attempts = 0
    begin
      raw = uri.open(progress_proc: ->(size) { raise(IOError, 'too large') if size > 20.gigabytes })
    rescue URI::InvalidURIError => e
      raise e if attempts.positive?
      fix_encoding_for_sanitized_source_url
      attempts += 1
      retry
    rescue Net::ReadTimeout
      mess = "Timed out reading #{get_url} for Medium ##{self[:id]}"
      harvest.log(mess, cat: :errors)
      raise Net::ReadTimeout, mess
    rescue IOError => e
      mess = "File too large reading #{get_url} for Medium ##{self[:id]}"
      harvest.log(mess, cat: :errors)
      raise e
    end
    abort_empty_download if raw.nil?
    raw
  end

  def abort_empty_download
    mess = "#{get_url} was empty. Medium.find(#{self[:id]}) resource: #{resource.name} (#{resource.id}), PK: #{resource_pk}"
    Delayed::Worker.logger.error(mess)
    harvest.log(mess, cat: :errors)
    raise 'empty'
  end

  def abort_if_filetype_unreadable
    if sanitized_source_url.match?(/\.svg\b/)
      mess = "Medium.find(#{self[:id]}) resource: #{resource.name} (#{resource.id}), PK: #{resource_pk} is an SVG "\
        "(#{sanitized_source_url}). Aborting."
      Delayed::Worker.logger.error(mess)
      harvest.log(mess, cat: :errors)
      raise 'empty'
    # elsif sanitized_source_url.match?(/\.ogv\b/)
    #   mess = "Medium.find(#{self[:id]}) resource: #{resource.name} (#{resource.id}), PK: #{resource_pk} is an OGV "\
    #     "*video* (#{sanitized_source_url}). Aborting."
    #   Delayed::Worker.logger.error(mess)
    #   harvest.log(mess, cat: :errors)
    #   raise 'empty'
    end
  end

  def get_prepper(raw)
    content_type = raw.content_type
    @valid_type_res ||= {
      /^image/ => MediumPrepper::Image,
      %r{application/octet-stream} => MediumPrepper::Image,
      %r{application/ogg} => MediumPrepper::Ogg,
      /^svg/ => MediumPrepper::Image
    }
    @valid_type_res.each do |re, klass|
      return klass.new(self, raw) if content_type.downcase.match?(re)
    end
    # NOTE: No, I'm not using the rescue block below to handle this; different behavior, ugly to generalize. This is
    # clearer.
    mess = "#{get_url} is #{content_type}, NOT an image. Medium.find(#{self[:id]}) resource: #{resource.name} "\
      "(#{resource.id}), PK: #{resource_pk}"
    Delayed::Worker.logger.error(mess)
    harvest.log(mess, cat: :errors)
    raise TypeError, mess # NO, this isn't "really" a TypeError, but it makes enough sense to use it. KISS.
  end
end
