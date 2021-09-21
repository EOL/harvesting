module MediumPrepper
  class ImageSizeCreator
    def initialize(medium, image) 
      # image is a Magick::Image
      @medium = medium
      @image = image
    end

    def create_size(size, options = {})
      filename = "#{@medium.dir}/#{@medium.basename}.#{size}.#{@ext}"
      # NOTE: we *used* to skip existing images here, but I think that's actually unwise, so... let's just do it again.
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
      local_quality = MediumPrepper::ResizableImage::IMAGE_QUALITY
      this_image.write(filename) { |img| img.quality = local_quality }
      this_image.destroy! # Reclaim memory.
      # Note: we *should* honor crops. But none of these will have been cropped (yet), so I am skipping it for now.
      FileUtils.chmod(0o644, filename)

      new_size = "#{new_w}x#{new_h}"

      update_available_sizes(size, new_size) if options[:update_available_sizes]

      new_size
    end

    private
    def update_available_sizes(size, size_str)
      available_sizes = JSON.parse(@medium.sizes)
      available_sizes[size] = size_str
      @medium.update!(sizes: JSON.generate(available_sizes))
    end
  end
end
