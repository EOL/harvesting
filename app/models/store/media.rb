module Store
  module Media
    def to_media_pk(field, val)
      @models[:medium] ||= {}
      @models[:medium][:resource_pk] = val
    end

    def to_media_nodes_fk(field, val)
      @models[:medium] ||= {}
      @models[:medium][:node_resource_pk] = val # we will "find" it later.
    end

    def to_media_type(field, val)
      @models[:medium] ||= {}
      # TODO: lots more to these mappings, especially the URIs that commonly get
      # used.
      @media_type_mappings ||= {
        "image" => :image,
        "video" => :video,
        "sound" => :sound,
        "map_image" => :map_image,
        "map_js" => :map_js
      }
      type = if @media_type_mappings.has_key?(val.downcase)
        @media_type_mappings[val.downcase]
      else
        debugger
        field.format.warn("Could not find a media subtype of \"#{val.downcase}\"",
          @line_num)
        :image
      end
      @models[:medium][:subclass] = Medium.subclasses[type]
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
  end
end
