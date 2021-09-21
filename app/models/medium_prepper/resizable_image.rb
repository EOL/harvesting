module MediumPrepper
  # Used to prepare a Medium with an image subclass for publishing, by normalizing the file type, cropping it for some
  # versions, resizing it for others, and then storing information about it in the DB.
  class ResizableImage
    include Magick # Allows "Image" in this namespace, as well as the methods we'll manipulate them with.
    # NOTE: if you want to use this at a prompt, replace Image with Magick::Image
    IMAGE_QUALITY = 60

    def initialize(medium, raw)
      @downloaded_at = Time.now
      @medium = medium
      @available_sizes = {}
      @orig_w = 0
      @orig_h = 0
      # NOTE: you can try changing this to make for faster downloads (smaller values, down to 10) or better
      # representation of the original (higher values, up to 100)
      @our_quality = IMAGE_QUALITY
      @ext = Medium::IMAGE_EXT
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
        mess = "Couldn't parse image for Medium ##{@medium.id} (#{e.message})"
        Delayed::Worker.logger.error(mess)
        @medium.resource.log_error(mess)
        raise 'unparsable'
      ensure
        raw = nil # Hand it to GC. I am not sure this actually helps, but I am paranoid about removing it. :|
      end
    end

    def get_image(raw)
      # NOTE: #first because no animations are supported!
      if raw.respond_to?(:to_io)
        # NOTE: if you want to use this at a prompt, replace Image with Magick::Image
        Magick::Image.read(raw.path).first
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
      orig_filename = @medium.original_image_path
      return if File.exist?(orig_filename)
      local_quality = @our_quality
      @image.write(orig_filename) { |img| img.quality = local_quality }
      FileUtils.chmod(0o644, orig_filename)
    end

    def create_alternative_sizes
      @orig_w = @image.columns
      @orig_h = @image.rows
      @available_sizes = { original: "#{@orig_w}x#{@orig_h}" }
      size_creator = ImageSizeCreator.new(@medium, @image)
      Medium.sizes.each do |size|
        available = size_creator.create_size(size)
        @available_sizes[size] = available if available
      end
    end

    def get_image_size(filename)
      this_image = Image.read(filename).first
      this_w = this_image.columns
      this_h = this_image.rows
      "#{this_w}x#{this_h}"
    end
  end
end
