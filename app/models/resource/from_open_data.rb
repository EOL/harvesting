class Resource
  class FromOpenData
    def self.url(url)
      self.new(url).parse
    end

    def initialize(url)
      # E.g.: https://opendata.eol.org/dataset/anage/resource/2af10fa0-db2a-4908-bc85-505f691419dd
      @url = url
      @partner = nil
    end

    def parse
      noko = noko_parse(@url)
      create_resource(noko)
      get_partner_info(noko.css('.breadcrumb li a')[-2])
      @resource.fake_partner if @partner.nil?
      file = download_resource(noko.css('p.muted a').first['href'], @resource.abbr)
      dir = DropDir.unpack_file(file)
      # TODO: Find Excel and write a .from_excel method much like .from_xml...
      if File.exist?("#{dir}/meta.xml")
        Resource.from_xml(dir, @resource)
        log("...Will harvest resource #{@resource.name} (#{@resource.id})")
        @resource.enqueue
      else
        fail_with(Exception.new("DropDir: New Resource (#{dir}), but no meta.xml. Cannot proceed!"))
      end
      @resource
    end

    def noko_parse(url)
      require 'open-uri'
      begin
        raw = open(url)
      rescue Net::ReadTimeout => e
        fail_with(e)
      end
      fail_with(Exception.new('URL returned empty result.')) if raw.blank?
      Nokogiri::HTML(raw)
    end

    def create_resource(noko)
      name = strip_string(noko.css('h1').first.text)
      abbr = abbreviate(name)
      desc = noko.css('.prose p,blockquote').map(&:text).map { |txt| strip_string(txt) }.join("\n")
      @resource = Resource.create(name: name, abbr: abbr, description: desc, notes: 'auto-harvested, requires editing.',
                                  opendata_url: @url)
    end

    def get_partner_info(link)
      return nil unless link
      partner_noko = noko_parse(URI.join(@url, link['href']).to_s)
      partner_name = strip_string(partner_noko.css('h1').first.text)
      partner_name.sub!(/\s*\(#{@resource.name}\)$/, '')
      partner_description = partner_noko.css('.notes p').map(&:text).join("\n")
      partner_abbr = abbreviate(partner_name)
      @partner = Partner.create(
        name: partner_name,
        abbr: partner_abbr,
        short_name: shorten(partner_name),
        homepage_url: "#{partner_abbr.downcase}.com",
        description: partner_description,
        auto_publish: false
      )
      @resource.update_attribute(:partner_id, @partner.id)
    end

    def download_resource(link, abbr)
      ext = 'tgz'
      ext = 'zip' if link.match?(/zip$/)
      path = Rails.public_path.join('tmp', 'resource_files')
      FileUtils.mkdir_p(path) unless Dir.exist?(path)
      path = path.join("#{abbr}.#{ext}")
      require 'open-uri'
      File.open(path, 'wb') do |file|
        open(link, 'rb') do |input|
          file.write(input.read)
        end
      end
      raise('Did not download') unless File.exist?(path) && File.size(path).positive?
      path
    end

    def strip_string(str)
      str.gsub(/\W+/m, ' ').gsub(/^\s+/m, '').gsub(/\s+$/m, '')
    end

    def abbreviate(name)
      return name if name.size < 8
      words = name.split
      abbr = if words.size > 4
        words.map { |w| w.first }.join
      elsif name.sub(/[^A-Z]/, '').size >= 3
        name.sub(/[^A-Z]/, '')
      else
        name[0..7]
      end
      abbr.gsub(/\s+/, '_')
    end

    def shorten(name)
      return name if name.size < 8
      words = name.split
      if words.size > 4
        return words[0..1]
      elsif name.sub(/[^A-Z]/, '').size >= 3
        return name.sub(/[^A-Z]/, '')
      else
        return name[0..15]
      end
    end

    def log(message, options = {})
      options[:cat] ||= :starts
      # for now...
      puts "[#{Time.now.strftime('%H:%M:%S.%3N')}](#{options[:cat]}) #{message}"
      STDOUT.flush
    end

    def fail_with(e)
      log(e.message, cat: :errors)
      raise e
    end
  end
end
