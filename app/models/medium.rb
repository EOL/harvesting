class Medium < ApplicationRecord
  belongs_to :resource, inverse_of: :media
  belongs_to :harvest, inverse_of: :media
  belongs_to :node, inverse_of: :media
  belongs_to :license, inverse_of: :media
  belongs_to :language
  belongs_to :location, inverse_of: :media
  belongs_to :bibliographic_citation
  belongs_to :downloaded_url

  has_many :media_references, inverse_of: :medium
  has_many :references, through: :media_references
  has_many :content_attributions, as: :content
  has_many :attributions, through: :content_attributions


  # NOTE: these MUST be kept in sync with the eol_website codebase! Be careful. Sorry for the conflation.
  enum subclass: %i[image video sound map_image js_map]
  enum format: {
    jpg: 0,
    youtube: 1,
    flash: 2, # deprecated
    vimeo: 3,
    mp3: 4,
    ogg: 5,
    wav: 6,
    mp4: 7,
    ogv: 8,
    mov: 9, # deprecated
    svg: 10,
    webm: 11
  }

  scope :published, -> { where(removed_by_harvest_id: nil) }
  scope :missing, -> { where('base_url IS NULL') }
  scope :needs_download, -> { where(downloaded_at: nil) }
  scope :failed_download, -> { where('downloaded_at IS NOT NULL AND base_url IS NULL') }

  IMAGE_EXT = 'jpg'

  class << self
    attr_accessor :sizes, :bucket_size

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

  def id_to_use_for_storage
    id_to_use_for_storage ||= if (Rails.application.secrets.image_path.has_key?(:legacy_medium_id) &&
        Rails.application.secrets.image_path[:legacy_medium_id])
      id
    else
      if downloaded_url_id.nil?
        create_downloaded_url
      else
        resource.update_attribute(:downloaded_media_count, resource.downloaded_media_count + 1)
      end
      downloaded_url_id
    end
  end

  def create_downloaded_url(md5_hash = nil)
    md5_hash ||= Digest::MD5.hexdigest(source_url)
    # NOTE: yes, the downloaded_url shares the ID with the first medium that creates it. This is just to avoid collisions.
    durl = DownloadedUrl.create(id: id, resource_id: resource_id, url: source_url, md5_hash: md5_hash)
    update_attribute(:downloaded_url_id, durl.id)
  end

  def s_dir
    dir_from_mod(id_to_use_for_storage)
  end

  def m_num
    id_to_use_for_storage / Medium.bucket_size
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

  def embedded_video?
    youtube? || vimeo?
  end

  def default_base_url
    "#{path}/#{basename}"
  end

  def default_unmodified_url
    if embedded_video?
      ''
    else
      "#{default_base_url}.#{file_ext}"
    end
  end

  def file_ext
    raise TypeError, "file_ext undefined for embedded videos" if embedded_video?
    format
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
    uri = Addressable::URI.parse(source_url.sub(/^https/, 'http'))
    @sanitized_source_url ||= uri.normalize.to_s
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
      if downloaded_already?
        create_missing_image_sizes # This will skip sizes that already exist.
      else
        abort_if_filetype_unreadable
        raw = download_raw_data
        prepper = get_prepper(raw)
        raw = nil # Ensure it's not taking up memory anymore (well, modulo GC). It c/b quite large!
        prepper.prep_medium
      end
    rescue => e
      return fail_from_download_and_prep(e)
    end
  end

  def downloaded_already?
    return false unless create_missing_downloaded_url.nil?
    File.exist?(original_image_path)
  end

  def create_missing_downloaded_url
    return nil unless downloaded_url.nil?
    downloaded_url = DownloadedUrl.create(resource_id: resource_id, url: source_url)
  end

  def fail_from_download_and_prep(e)
    update_attribute(:downloaded_at, Time.now) # Avoid attempting it again...
    resource.update_attribute(:failed_downloaded_media_count, resource.failed_downloaded_media_count + 1)
    resource.log_error("download_and_prep FAILED for Medium.find(#{self[:id]}): #{e.message[0..1000]}")
    nil
  end

  def safe_name
    name.blank? ? "#{subclass.titleize} of #{node.canonical}" : name
  end

  def download_raw_data
    require 'open-uri'
    attempts = 0
    begin
      raw = URI.open(sanitized_source_url, progress_proc: ->(size) { raise(IOError, 'too large') if size > 20.gigabytes })
    rescue URI::InvalidURIError => e
      raise e if attempts.positive?
      fix_encoding_for_sanitized_source_url
      attempts += 1
      retry
    rescue Net::ReadTimeout
      mess = "Timed out reading #{sanitized_source_url} for Medium ##{self[:id]}"
      resource.log_error(mess)
      raise Net::ReadTimeout, mess
    rescue IOError => e
      mess = "File too large reading #{sanitized_source_url} for Medium ##{self[:id]}"
      resource.log_error(mess)
      raise e
    end
    abort_empty_download if raw.nil?
    raw
  end

  def abort_empty_download
    mess = "#{sanitized_source_url} was empty. Medium.find(#{self[:id]}) resource: #{resource.name} (#{resource.id}), PK: #{resource_pk}"
    Delayed::Worker.logger.error(mess)
    resource.log_error(mess)
    raise 'empty'
  end

  def abort_if_filetype_unreadable
    if sanitized_source_url.match?(/\.svg\b/)
      mess = "Medium.find(#{self[:id]}) resource: #{resource.name} (#{resource.id}), PK: #{resource_pk} is an SVG "\
        "(#{sanitized_source_url}). Aborting."
      Delayed::Worker.logger.error(mess)
      resource.log_error(mess)
      raise 'empty'
    end
  end

  def get_prepper(raw)
    content_type = raw.content_type
    @valid_type_res ||= {
      /^image/ => MediumPrepper::ResizableImage,
      %r{application/octet-stream} => MediumPrepper::ResizableImage,
      %r{application/ogg} => MediumPrepper::SaveAndServe,
      %r{audio/mpeg} => MediumPrepper::SaveAndServe,
      %r{audio/wav} => MediumPrepper::SaveAndServe,
      %r{audio/x-wav} => MediumPrepper::SaveAndServe,
      %r{video/mp4} => MediumPrepper::SaveAndServe,
      %r{video/quicktime} => MediumPrepper::SaveAndServe,
      %r{image/svg+xml} => MediumPrepper::SaveAndServe,
      %r{video/webm} => MediumPrepper::SaveAndServe,
      %r{audio/webm} => MediumPrepper::SaveAndServe
    }
    @valid_type_res.each do |re, klass|
      return klass.new(self, raw, File) if content_type.downcase.match?(re)
    end
    # NOTE: No, I'm not using the rescue block below to handle this; different behavior, ugly to generalize. This is
    # clearer.
    mess = "#{sanitized_source_url} is #{content_type}, which is unsupported. Medium.find(#{self[:id]}) resource: "\
      "#{resource.name} (#{resource.id}), PK: #{resource_pk}"
    Delayed::Worker.logger.error(mess)
    resource.log_error(mess)
    raise TypeError, mess # NO, this isn't "really" a TypeError, but it makes enough sense to use it. KISS.
  end

  def original_image_path
    assert_jpg
    "#{dir}/#{basename}.#{IMAGE_EXT}"
  end

  def create_missing_image_sizes
    size_creator = MediumPrepper::ImageSizeCreator.new(
      self,
      Magick::Image.read(original_image_path).first
    )

    missing_size_creator = MediumPrepper::MissingImageSizeCreator.new(
      self,
      self.class.sizes,
      size_creator
    )

    missing_size_creator.create_missing_sizes
  end

  def update_sizes(new_sizes)
    self.update(sizes: JSON.generate(JSON.parse(self.sizes).merge(new_sizes)))
  end

  private
  def assert_jpg
    raise TypeError, "must be jpg" unless jpg?
  end
end
