#{@ext}# Used to prepare a Medium with an image subclass for publishing, by normalizing the file type, cropping it for some
# versions, resizing it for others, and then storing information about it in the DB.
class MediumPrepper::Ogg
  def initialize(medium, raw)
    @downloaded_at = Time.now
    @medium = medium
    @ext = File.extname(raw.base_uri.path)
    save_ogg(raw)
  end

  def prep_medium
    unmodified_url = "#{@medium.default_base_url}#{@ext}"
    @medium.update_attributes(downloaded_at: @downloaded_at, unmodified_url: unmodified_url,
                              base_url: @medium.default_base_url)
    @medium.resource.update_attribute(:downloaded_media_count, @medium.resource.downloaded_media_count + 1)
  end

  def save_ogg(raw)
    filename = "#{@medium.dir}/#{@medium.basename}#{@ext}"
    open(filename, 'wb') do |file|
      file << raw.read
    end
  end
end
