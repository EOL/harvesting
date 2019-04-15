#{@ext}# Used to prepare a Medium with an image subclass for publishing, by normalizing the file type, cropping it for some
# versions, resizing it for others, and then storing information about it in the DB.
class MediumPrepper::SaveAndServe
  def initialize(medium, raw)
    @downloaded_at = Time.now
    @medium = medium
    get_ext(raw.base_uri)
    save_ogg(raw)
  end

  def get_ext(base_uri)
    @ext = begin
             File.extname(base_uri.path).downcase
           rescue => e
             raise "Unable to parse #{base_uri} for ext (#{e.class}: #{e.message})"
           end
    valid_exts = %w[mp3 ogg wav mp4 ogv mov svg webm]
    raise "#{raw.base_uri} is not a valid save-and-serve type (one of #{valid_exts.join(', ')}): #{@ext}" unless
      valid_exts.includes?(@ext)
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
