class Medium < ActiveRecord::Base
  include Magick # Allows "Image" in this namespace, as well as the methods we'll manipulate them with.

  belongs_to :resource, inverse_of: :media
  belongs_to :harvest, inverse_of: :media
  belongs_to :node, inverse_of: :media
  belongs_to :license
  belongs_to :language
  belongs_to :location, inverse_of: :media
  belongs_to :bibliographic_citation

  has_many :media_references, inverse_of: :medium
  has_many :references, through: :media_references

  enum subclass: [:image, :video, :sound, :map_image ]
  enum format: [:jpg, :youtube, :flash, :vimeo, :mp3, :ogg, :wav]

  scope :published, -> { where(removed_by_harvest_id: nil) }

  class << self
    attr_accessor :sizes, :bucket_size
  end

  @sizes = %w[88x88 98x68 580x360 130x130 260x190]
  @bucket_size = 256

  def dir
    s_dir = dir_from_mod(id)
    m_num = id / Medium.bucket_size
    m_dir = dir_from_mod(m_num)
    l_num = m_num / Medium.bucket_size
    l_dir = dir_from_mod(l_num)
    Rails.public_path.join('data', 'media', l_dir, m_dir, s_dir)
  end

  def dir_from_mod(mod)
    '%02x' % (mod % Medium.bucket_size)
  end

  def download_and_resize
    harvest.log("download_and_resize (#{id})")
    available_sizes = {}
    d_time = nil
    unless Dir.exist?(dir)
      FileUtils.mkdir_p(dir)
      FileUtils.chmod(0755, dir)
    end
    orig_filename = "#{dir}/#{id}.jpg"
    begin
      # TODO: we really should use https. It will be the only thing availble, at some point...
      get_url = source_url.sub(/^https/, "http")
      image = Image.read(get_url).first # No animations supported!
      d_time = Time.now
    rescue Magick::ImageMagickError => e
      logger.error("Couldn't get image #{get_url} for #{url}")
      return nil
    end
    orig_w = image.columns
    orig_h = image.rows
    image.format = 'JPEG'
    if File.exist?(orig_filename)
      logger.warn "Hmmmn. There was already a #{orig_filename} for #{id}. Skipping."
    else
      image.write(orig_filename)
      FileUtils.chmod(0644, orig_filename)
    end
    Medium.sizes.each do |size|
      filename = "#{dir}/#{id}.#{size}.jpg"
      unless File.exist?(filename)
        (w, h) = size.split("x").map { |e| e.to_i }
        this_image = if w == h
          image.resize_to_fill(w, h).crop(NorthWestGravity, w, h)
        else
          image.resize_to_fit(w, h)
        end
        new_w = this_image.columns
        new_h = this_image.rows
        available_sizes[size] = "#{new_w}x#{new_h}"
        this_image.strip! # Cleans up properties
        this_image.write(filename) { self.quality = 80 }
        this_image.destroy! # Reclaim memory.
        # Note: we *should* honor crops. But none of these will have been
        # cropped, so I am skipping it for now.
        FileUtils.chmod(0644, filename)
      end
    end
    unmodified_url = orig_filename.gsub(Rails.public_path.to_s, '')
    base_url = unmodified_url.gsub(/\..*$/, '')
    update_attributes(sizes: JSON.generate(available_sizes), w: orig_w, h: orig_h, downloaded_at: d_time,
                      unmodified_url: unmodified_url, base_url: base_url)
    image.destroy! # Clear memory
  end

  def safe_name
    name.blank? ? "#{subclass.titleize} of #{node.canonical}" : name
  end
end
