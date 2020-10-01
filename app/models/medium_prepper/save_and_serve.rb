module MediumPrepper
  # Used to prepare a Medium with an image subclass for publishing, by normalizing the file type, cropping it for some
  # versions, resizing it for others, and then storing information about it in the DB.
  class SaveAndServe
    def initialize(medium, raw)
      @downloaded_at = Time.now
      @medium = medium
      get_ext
      save_ogg(raw)
    end

    def get_ext
      @ext = @medium.file_ext
      raise TypeError, "failed to get ext for Medium (#{@medium.id}, #{@medium.subclass}, #{@medium.format}" if @ext.nil?
    end

    def prep_medium
      unmodified_url = "#{@medium.default_base_url}.#{@ext}"
      @medium.update_attributes(downloaded_at: @downloaded_at, unmodified_url: unmodified_url,
                                base_url: @medium.default_base_url)
      @medium.resource.update_attribute(:downloaded_media_count, @medium.resource.downloaded_media_count + 1)
    end

    def save_ogg(raw)
      filename = "#{@medium.dir}/#{@medium.basename}.#{@ext}"
      File.open(filename, 'wb') do |file|
        file << raw.read
      end
    end
  end
end
