module Store
  module Media
    extend ActiveSupport::Concern
    include ActionView::Helpers::SanitizeHelper

    def to_media_pk(field, val)
      @models[:medium] ||= {}
      @models[:medium][:resource_pk] = val
    end

    def to_media_nodes_fk(field, val)
      @models[:medium] ||= {}
      @models[:medium][:node_resource_pk] = val # we will 'find' it later.
    end

    def to_media_language(field, val)
      @models[:medium] ||= {}
      @models[:medium][:language_code_verbatim] = val # we will 'find' it later.
    end

    # Sets subclass. NOT format.
    def to_media_type(field, val)
      @models[:medium] ||= {}
      return if @models[:medium].key?(:subclass) # We've already got one.
      @media_type_mappings ||= {
        'image' => :image,
        'video' => :video,
        'sound' => :sound,
        'map' => :map_image,
        'map_image' => :map_image,
        'map_js' => :map_js,
        'http://purl.org/dc/dcmitype/stillimage' => :image,
        'http://purl.org/dc/dcmitype/movingimage' => :video,
        'http://purl.org/dc/dcmitype/text' => :article,
        'http://purl.org/dc/dcmitype/sound' => :sound
      }
      norm_val = val.downcase
      type = if @media_type_mappings.key?(norm_val)
        @media_type_mappings[norm_val]
      else
        @process.warn(%Q{Could not find a media type (subclass) of "#{norm_val}"}) unless
          @missing_media_types.key?(norm_val)
        @missing_media_types[norm_val] = true
        nil
      end
      @models[:medium][:original_type] = norm_val
      @models[:medium][:subclass] = type
      @models[:medium][:is_article] = true if type == :article
    end

    # http://rs.tdwg.org/audubon_core/subtype
    # Sets format, and *possibly* subclass, if one is strictly inferred. Best to set subclass with to_media_type
    def to_media_subtype(field, val)
      @models[:medium] ||= {}
      @media_subtype_mappings ||= {
        'image/jpeg' => :jpg,
        'image/gif' => :jpg, # It will be converted.
        'video/x-youtube' => :youtube,
        'video/vimeo' => :vimeo,
        'video/mp4' => :mp4,
        'video/quicktime' => :mov,
        'application/javascript' => :map_js,
        'audio/mpeg' => :mp3, # NOTE: this one is "best".
        'audio/mp3' => :mp3,
        'audio/ogg' => :ogg, # NOTE: this one is "best"
        'video/ogg' => :ogg,
        'application/ogg' => :ogg,
        'audio/wav' => :wav,
        'audio/x-wav' => :wav,
        'text/html' => nil, # Nothing needed; this is just an article!
        'map' => :map_image,
        'map_image' => :map_image
      }
      norm_val = val.downcase
      type = if @media_subtype_mappings.key?(norm_val)
               @media_subtype_mappings[norm_val]
             else
               @process.warn(%Q{Could not find a media subtype (format) of "#{norm_val}"}) unless
                 @missing_media_types.key?(norm_val)
               @missing_media_types[norm_val] = true
               nil
             end
      @models[:medium][:original_format] = norm_val
      if type == :map_image
        @models[:medium][:subclass] = type # Maps are a SUBCLASS in this code, but were a "format" in v2...
      else
        @models[:medium][:format] = type
      end
    end

    def to_section(field, val)
      @models[:medium] ||= {}
      @models[:medium][:section_value] = val
    end

    def to_bibliographic_citation(field, val)
      @models[:medium] ||= {}
      @models[:medium][:bib_cit] = clean_string(val)
    end

    def to_media_name(field, val)
      @models[:medium] ||= {}
      @models[:medium][:name_verbatim] = clean_string(val)
      @models[:medium][:name] = sanitize(@models[:medium][:name_verbatim])
    end

    def to_media_license(field, val)
      @models[:medium] ||= {}
      @models[:medium][:license_url] = val
    end

    def to_media_description(field, val)
      @models[:medium] ||= {}
      @models[:medium][:description_verbatim] = clean_string(val)
      @models[:medium][:description] = sanitize(@models[:medium][:description_verbatim])
    end

    # http://rs.tdwg.org/ac/terms/accessURI (where to fetch the media file)
    def to_media_source_url(field, val)
      @models[:medium] ||= {}
      @models[:medium][:source_url] = clean_string(val)
    end

    # http://rs.tdwg.org/ac/terms/furtherInformationURL (where the link accompanying the media object should point)
    def to_media_source_page_url(field, val)
      @models[:medium] ||= {}
      @models[:medium][:source_page_url] = clean_string(val)
    end

    def to_media_owner(field, val)
      @models[:medium] ||= {}
      @models[:medium][:owner] = clean_string(val)
    end

    def to_media_rights_statement(field, val)
      @models[:medium] ||= {}
      @models[:medium][:rights_statement] = clean_string(val)
    end

    def to_media_usage_statement(field, val)
      @models[:medium] ||= {}
      @models[:medium][:usage_statement] = clean_string(val)
    end

    def to_media_ref_fks(field, val)
      @models[:medium] ||= {}
      @models[:medium][:ref_sep] ||= field.submapping
      @models[:medium][:ref_fks] = val
    end

    def to_media_attributions_fk(field, val)
      @models[:medium] ||= {}
      @models[:medium][:attribution_sep] ||= field.submapping
      @models[:medium][:attributions] = val
    end

    def to_media_lat(field, val)
      @models[:location] ||= {}
      @models[:location][:lat] = val
    end

    def to_media_long(field, val)
      @models[:location] ||= {}
      @models[:location][:long] = val
    end

    def to_media_lat_literal(field, val)
      @models[:location] ||= {}
      @models[:location][:lat_literal] = val
    end

    def to_media_long_literal(field, val)
      @models[:location] ||= {}
      @models[:location][:long_literal] = val
    end

    # http://iptc.org/std/Iptc4xmpExt/1.0/xmlns/LocationCreated <-- Measurement location
    # http://purl.org/dc/terms/spatial <-- Spatial location
    # The distinction is usually explained with the example of a photographer on a mountain, with a telephoto lens,
    # photographing a mountain goat on the neighboring mountain. The first field is the location of the camera. The
    # second, the location of the goat.
    def to_media_locality(field, val)
      @models[:location] ||= {}
      @models[:location][:locality] = val
    end

    def clean_string(val)
      return nil if val.nil?
      return '' if val.blank?
      val.gsub(/""+/, '"').gsub(/^\s+/, '').gsub(/\s+$/, '').gsub(/^\"\s*(.*)\s*\"$/, '\\1')
    end
  end
end
