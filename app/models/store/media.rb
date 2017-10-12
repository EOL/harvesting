module Store
  module Media
    def to_media_pk(field, val)
      @models[:medium] ||= {}
      @models[:medium][:resource_pk] = val
    end

    def to_media_nodes_fk(field, val)
      @models[:medium] ||= {}
      @models[:medium][:node_resource_pk] = val # we will 'find' it later.
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
        'http://purl.org/dc/dcmitype/stillimage' => :image
      }
      type = if @media_type_mappings.key?(val.downcase)
        @media_type_mappings[val.downcase]
      else
        debugger
        log_warning(%Q{Could not find a media type (subclass) of "#{val.downcase}"})
        :image
      end
      @models[:medium][:subclass] = type
    end

    def to_media_subtype(field, val)
      @media_subtype_mappings ||= {
        'image/jpeg' => :jpg,
        'video/x-youtube' => :youtube,
        'application/x-shockwave-flash' => :flash,
        'video/vimeo' => :vimeo,
        'application/javascript' => :map_js,
        'audio/mpeg' => :mp3, # NOTE: this one is "best".
        'audio/mp3' => :mp3,
        'audio/ogg' => :ogg, # NOTE: this one is "best"
        'application/ogg' => :ogg,
        'audio/wav' => :wav
      }
      type = if @media_subtype_mappings.key?(val.downcase)
        @media_subtype_mappings[val.downcase]
      else
        debugger
        log_warning(%Q{Could not find a media subtype (format) of "#{val.downcase}"})
        :jpg
      end
      @models[:medium][:format] = type
    end

    def to_media_name(field, val)
      @models[:medium] ||= {}
      @models[:medium][:name] = val
    end

    def to_media_description(field, val)
      @models[:medium] ||= {}
      @models[:medium][:description] = val
    end

    def to_media_source_url(field, val)
      @models[:medium] ||= {}
      @models[:medium][:source_url] = val
    end

    def to_media_source_url(field, val)
      @models[:medium] ||= {}
      @models[:medium][:source_url] = val
    end

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

    def to_media_ref_fk(field, val)
      @models[:location] ||= {}
      @models[:location][:ref_fk] = val
    end

    def to_media_locality(field, val)
      @models[:location] ||= {}
      @models[:location][:locality] = val
    end
  end
end
