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

    def to_media_type(field, val)
      @models[:medium] ||= {}
      # TODO: lots more to these mappings, especially the URIs that commonly get used.
      @media_type_mappings ||= {
        'image' => :image,
        'video' => :video,
        'sound' => :sound,
        'map_image' => :map_image,
        'map_js' => :map_js,
        'http://purl.org/dc/dcmitype/stillimage' => :image,
        'http://purl.org/dc/dcmitype/movingimage' => :video,
        'http://purl.org/dc/dcmitype/text' => :article
      }
      norm_val = val.downcase
      type = if @media_type_mappings.key?(norm_val)
        @media_type_mappings[norm_val]
      else
        log_warning(%Q{Could not find a media type (subclass) of "#{norm_val}"}) unless
          @missing_media_types.key?(norm_val)
        @missing_media_types[norm_val] = true
        :image
      end
      @models[:medium][:subclass] = type
      @models[:medium][:is_article] = true if type == :article
    end

    def to_media_subtype(field, val)
      @media_subtype_mappings ||= {
        'image/jpeg' => :jpg,
        'image/gif' => :jpg, # It will be converted.
        'video/x-youtube' => :youtube,
        'application/x-shockwave-flash' => :flash,
        'video/vimeo' => :vimeo,
        'video/mp4' => :mp4,
        'application/javascript' => :map_js,
        'audio/mpeg' => :mp3, # NOTE: this one is "best".
        'audio/mp3' => :mp3,
        'audio/ogg' => :ogg, # NOTE: this one is "best"
        'application/ogg' => :ogg,
        'audio/wav' => :wav,
        'text/html' => nil, # Nothing needed; it's just an article!
      }
      norm_val = val.downcase
      type = if @media_subtype_mappings.key?(norm_val)
        @media_subtype_mappings[norm_val]
      else
        log_warning(%Q{Could not find a media subtype (format) of "#{norm_val}"}) unless
          @missing_media_types.key?(norm_val)
        @missing_media_types[norm_val] = true
        :jpg
      end
      @models[:medium][:format] = type
    end

    def to_section(field, val)
      # TODO ... argh. The values are a controlled vocabulary, which we may edit in the future, but not for MVP. It's
      # drawn from a couple of sources and contains some homegrown terms also. It's documented at
      # http://eol.org/info/toc_subjects. The URI for the field is http://iptc.org/std/Iptc4xmpExt/1.0/xmlns/CVterm
      # ...We will allow multiple values via a semicolon-delimited field.
    end

    def to_bibliographic_citation(field, val)
      # TODO ... argh.
    end

    def to_media_name(field, val)
      @models[:medium] ||= {}
      @models[:medium][:name_verbatim] = val
      @models[:medium][:name] = sanitize(val)
    end

    def to_media_license(field, val)
      @models[:medium] ||= {}
      @models[:medium][:license_url] = val
    end

    def to_media_description(field, val)
      @models[:medium] ||= {}
      @models[:medium][:description_verbatim] = val
      @models[:medium][:description] = sanitize(val)
    end

    # http://rs.tdwg.org/ac/terms/accessURI (where to fetch the media file)
    def to_media_source_url(field, val)
      @models[:medium] ||= {}
      @models[:medium][:source_url] = val
    end

    # http://rs.tdwg.org/ac/terms/furtherInformationURL (where the link accompanying the media object should point)
    def to_media_source_page_url(field, val)
      @models[:medium] ||= {}
      @models[:medium][:source_page_url] = val
    end

    def to_media_owner(field, val)
      @models[:medium] ||= {}
      @models[:medium][:owner] = val
    end

    def to_media_rights_statement(field, val)
      @models[:medium] ||= {}
      @models[:medium][:rights_statement] = val
    end

    def to_media_usage_statement(field, val)
      @models[:medium] ||= {}
      @models[:medium][:usage_statement] = val
    end

    def to_media_ref_fks(field, val)
      @models[:medium] ||= {}
      @models[:medium][:ref_sep] ||= field.submapping
      @models[:medium][:ref_fks] = val
    end

    def to_media_attributions_fk(field, val)
      @models[:medium] ||= {}
      @models[:medium][:attributions] ||= []
      @models[:medium][:attributions] << val
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
  end
end
