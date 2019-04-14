#{@ext}# Used to prepare a Medium with an image subclass for publishing, by normalizing the file type, cropping it for some
# versions, resizing it for others, and then storing information about it in the DB.
class MediumPrepper::Image
  include Magick # Allows "Image" in this namespace, as well as the methods we'll manipulate them with.

  def initialize(medium, raw)
    @downloaded_at = Time.now
    @medium = medium
    @available_sizes = {}
    @orig_w = 0
    @orig_h = 0
    # NOTE: you can try changing this to make for faster downloads (smaller values, down to 10) or better representation
    # of the original (higher values, up to 100)
    @our_quality = 60
    @ext = 'jpg'
    read_image(raw)
  end

  def prep_medium
    begin
      prep_image
    ensure
      clean_up
    end
  end

  def clean_up
    @image&.destroy!
    @image = nil
    # And, rudely, we delete anything open-uri may have left behind that's older than 10 minutes:
    delete_tmp_files_older_than_10_min('open-uri')
    delete_tmp_files_older_than_10_min('magic')
  end

  def delete_tmp_files_older_than_10_min(prefix)
    return unless Dir.glob("#{ENV['TMPDIR'] || '/tmp'}/#{prefix}*").any?
    `find #{ENV['TMPDIR'] || '/tmp'}/#{prefix}* -type f -mmin +10 -exec rm {} \\;`
  end

  def read_image(raw)
    begin
      @image = get_image(raw)
    rescue Magick::ImageMagickError => e
      mess = "Couldn't parse image #{get_url} for Medium ##{self[:id]} (#{e.message})"
      Delayed::Worker.logger.error(mess)
      @medium.harvest.log(mess, cat: :errors)
      raise 'unparsable'
    ensure
      raw = nil # Hand it to GC.
    end
  end

  def get_image(raw)
    # NOTE: #first because no animations are supported!
    if raw.respond_to?(:to_io)
      Image.read(raw.to_io).first
    else
      raw.rewind
      Image.from_blob(raw.read).first
    end
  end

  def prep_image
    @image.format = 'JPEG'
    @image.auto_orient
    store_original
    create_alternative_sizes
    unmodified_url = "#{@medium.default_base_url}.#{@ext}"
    @medium.update_attributes(sizes: JSON.generate(@available_sizes), w: @orig_w, h: @orig_h,
                              downloaded_at: @downloaded_at, unmodified_url: unmodified_url,
                              base_url: @medium.default_base_url)
    @medium.resource.update_attribute(:downloaded_media_count, @medium.resource.downloaded_media_count + 1)
  end

  def store_original
    orig_filename = "#{@medium.dir}/#{@medium.basename}.#{@ext}"
    return if File.exist?(orig_filename)
    local_quality = @our_quality
    @image.write(orig_filename) { self.quality = local_quality }
    FileUtils.chmod(0o644, orig_filename)
  end

  def create_alternative_sizes
    @orig_w = @image.columns
    @orig_h = @image.rows
    @available_sizes = { original: "#{@orig_w}x#{@orig_h}" }
    Medium.sizes.each do |size|
      available = crop_image(size)
      @available_sizes[size] = available if available
    end
  end

  def crop_image(size)
    filename = "#{@medium.dir}/#{@medium.basename}.#{size}.#{@ext}"
    if File.exist?(filename)
      mess = "#{filename} already exists. Skipping."
      Delayed::Worker.logger.warn(mess)
      @medium.harvest.log(mess, cat: :warns)
      return get_image_size(filename)
    end
    (w, h) = size.split('x').map(&:to_i)
    this_image =
      if w == h
        @image.resize_to_fill(w, h).crop(NorthWestGravity, w, h)
      else
        @image.resize_to_fit(w, h)
      end
    new_w = this_image.columns
    new_h = this_image.rows
    this_image.strip! # Cleans up properties
    local_quality = @our_quality
    this_image.write(filename) { self.quality = local_quality }
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
