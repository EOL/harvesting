class Medium < ActiveRecord::Base
  include Magick # Allows "Image" in this namespace, as well as the methods we'll manipulate them with.

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
  enum format: %i[jpg youtube flash vimeo mp3 ogg wav mp4]

  scope :published, -> { where(removed_by_harvest_id: nil) }
  scope :missing, -> { where(format: Medium.formats[:jpg], downloaded_at: nil) }
  scope :failed_download, -> { where(format: Medium.formats[:jpg], sizes: nil).where('downloaded_at IS NOT NULL') }

  class << self
    attr_accessor :sizes, :bucket_size

    def download_and_resize(images)
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

  def download_and_resize
    raw = nil
    image = nil
    begin
      unless Dir.exist?(dir)
        FileUtils.mkdir_p(dir)
        FileUtils.chmod(0o755, dir)
      end
      orig_filename = "#{dir}/#{basename}.jpg"
      # TODO: we really should use https. It will be the only thing availble, at some point...
      get_url = source_url.sub(/^https/, 'http')
      if get_url.match?(/\.svg\b/)
        mess = "Medium.find(#{self[:id]}) resource: #{resource.name} (#{resource.id}), PK: #{resource_pk} is an SVG "\
          "(#{get_url}). Aborting."
        Delayed::Worker.logger.error(mess)
        harvest.log(mess, cat: :errors)
        raise 'empty'
      end
      require 'open-uri'
      uri = URI.parse(get_url)
      attempts = 0
      begin
        raw = uri.open(progress_proc: ->(size) { raise(IOError, 'too large') if size > 20.gigabytes })
      rescue URI::InvalidURIError => e
        extend EncodingFixer
        puts "Unable to read #{get_url}"
        get_url = fix_encoding(get_url)
        puts "Re-trying with #{get_url}"
        raise e if attempts.positive?
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
      if raw.nil?
        mess = "#{get_url} was empty. Medium.find(#{self[:id]}) resource: #{resource.name} (#{resource.id}), PK: #{resource_pk}"
        Delayed::Worker.logger.error(mess)
        harvest.log(mess, cat: :errors)
        raise 'empty'
      end
      content_type = raw.content_type
      unless (content_type.match?(/^image/i) || content_type.match?(%r{application/octet-stream})) &&
             (!content_type.match?(/^svg/i))
        # NOTE: No, I'm not using the rescue block below to handle this; different behavior, ugly to generalize. This is
        # clearer.
        mess = "#{get_url} is #{content_type}, NOT an image. Medium.find(#{self[:id]}) resource: #{resource.name} "\
          "(#{resource.id}), PK: #{resource_pk}"
        Delayed::Worker.logger.error(mess)
        harvest.log(mess, cat: :errors)
        raise TypeError, mess # NO, this isn't "really" a TypeError, but it makes enough sense to use it. KISS.
      end
      begin
        # NOTE: #first because no animations are supported!
        image = if raw.respond_to?(:to_io)
                  Image.read(raw.to_io).first
                else
                  raw.rewind
                  Image.from_blob(raw.read).first
                end
      rescue Magick::ImageMagickError => e
        mess = "Couldn't parse image #{get_url} for Medium ##{self[:id]} (#{e.message})"
        Delayed::Worker.logger.error(mess)
        harvest.log(mess, cat: :errors)
        raise 'unparsable'
      ensure
        raw = nil # Hand it to GC.
      end
      d_time = Time.now
      orig_w = image.columns
      orig_h = image.rows
      available_sizes = {}
      image.format = 'JPEG'
      image.auto_orient
      if File.exist?(orig_filename)
        mess = "#{orig_filename} already exists. Skipping."
        Delayed::Worker.logger.warn(mess)
        harvest.log(mess, cat: :warns)
      else
        image.write(orig_filename)
        FileUtils.chmod(0o644, orig_filename)
      end
      Medium.sizes.each do |size|
        available = crop_image(image, size)
        available_sizes[size] = available if available
      end
      available_sizes[:original] = "#{orig_w}x#{orig_h}"
      unmodified_url = "#{default_base_url}.jpg"
      update_attributes(sizes: JSON.generate(available_sizes), w: orig_w, h: orig_h, downloaded_at: d_time,
                        unmodified_url: unmodified_url, base_url: default_base_url)
      resource.update_attribute(:downloaded_media_count, resource.downloaded_media_count + 1)
      harvest.log("download_and_resize completed for Medium.find(#{self[:id]}) /#{base_url}.260x190.jpg", cat: :downloads)
    rescue => e
      update_attribute(:downloaded_at, Time.now) # Avoid attempting it again...
      resource.update_attribute(:failed_downloaded_media_count, resource.failed_downloaded_media_count + 1)
      harvest.log("download_and_resize FAILED for Medium.find(#{self[:id]})", cat: :downloads)
      return nil
    ensure
      raw = nil
      image&.destroy!
      image = nil
      # And, rudely, we delete anything open-uri may have left behind that's older than 10 minutes:
      delete_tmp_files_older_than_10_min('open-uri')
      delete_tmp_files_older_than_10_min('magic')
    end
  end

  # TODO: This belongs in another class.
  def delete_tmp_files_older_than_10_min(prefix)
    begin
      `find #{ENV['TMPDIR'] || '/tmp'}/#{prefix}* -type f -mmin +10 -exec rm {} \\;`
    rescue
      nil # We don't need to worry about any errors.
    end
  end

  def safe_name
    name.blank? ? "#{subclass.titleize} of #{node.canonical}" : name
  end

  def crop_image(image, size)
    filename = "#{dir}/#{basename}.#{size}.jpg"
    if File.exist?(filename)
      mess = "#{filename} already exists. Skipping."
      Delayed::Worker.logger.warn(mess)
      harvest.log(mess, cat: :warns)
      return get_image_size(filename)
    end
    (w, h) = size.split('x').map(&:to_i)
    this_image =
      if w == h
        image.resize_to_fill(w, h).crop(NorthWestGravity, w, h)
      else
        image.resize_to_fit(w, h)
      end
    new_w = this_image.columns
    new_h = this_image.rows
    this_image.strip! # Cleans up properties
    this_image.write(filename) { self.quality = 80 }
    this_image.destroy! # Reclaim memory.
    # Note: we *should* honor crops. But none of these will have been cropped (yet), so I am skipping it for now.
    FileUtils.chmod(0o644, filename)
    "#{new_w}x#{new_h}"
  end

  def get_image_size(filename)
    this_image = Image.read(filename).first
    this_w = this_image.columns
    this_h = this_image.rows
    "#{this_w}x#{this_h}"
  end
end
