class Resource
  class FromOpenData
    class << self
      def url(url)
        new(url).parse
      end

      def reload(resource)
        EolFileUtils.clear_resource_dir(resource)
        new(resource.opendata_url, resource).parse
      end
    end

    def initialize(url, resource = nil)
      # E.g.: https://opendata.eol.org/dataset/anage/resource/2af10fa0-db2a-4908-bc85-505f691419dd
      @url = url
      @partner = nil
      @abbreviations = {
        america: 'am', american: 'am', arctic: 'arc', archaebacteria: 'arc', atlas: 'atl', australia: 'aus',
        australian: 'aus', bacteria: 'bac', biology: 'bio', catalog: 'cat', checklist: 'chk', checklists: 'chk',
        college: 'c', data: 'dat', database: 'db', distribution: 'dist', diversity: 'div', east: 'e', ecology: 'eco',
        ecological: 'eco', encyclopedia: 'enc', eubacteria: 'eub', fungi: 'fun', habitat: 'hab', harvard: 'hvd',
        hierarchy: 'hier', images: 'imgs', international: 'intl', interactions: 'int', journal: 'j', living: 'liv',
        mammal: 'mam', mammals: 'mam', marine: 'mar', measurements: 'meas', national: 'ntl', naturalist: 'nat',
        nature: 'nat', north: 'n', ocean: 'oc', oceans: 'oc', oceanic: 'oc', pictures: 'pics', plant: 'pl',
        plants: 'pl', planet: 'p', protist: 'prot', protista: 'prot', protists: 'prot', public: 'pub', record: 'rec',
        reference: 'ref', records: 'rec', register: 'reg', smithsonian: 'si', south: 's', species: 'sp', states: 's',
        structured: 'struct', summary: 'sum', test: 'tst', text: 'txt', university: 'u', universities: 'u', united: 'u',
        unitedstates: 'us', video: 'vid', videos: 'vid', wikimedia: 'wiki', wikipedia: 'wiki', west: 'w'
      }
      @stopwords = %w[a about all are an and be by do know or of on out for in is the this to was with what excel dwc
                      dwca]
      @resource = resource
      @partner = resource.partner if @resource
    end

    def parse
      noko = noko_parse(@url)
      create_resource(noko) unless @resource
      @process = @resource.logged_process
      @process.run_step('Creating resource from OpenData') do
        get_partner_info(noko.css('.breadcrumb li a')[-2]) unless @partner
        file = download_resource(noko.css('p.muted a').first['href'], @resource.abbr)
        path = @resource.path
        already_exists = File.exist?("#{path}/meta.xml") && @resource.formats.any?
        dir = DropDir.unpack_file(file)
        if already_exists
          @process.warn('...Resource already exists; re-reading XML...')
          @resource.re_read_xml
          @process.info('...new data is now in place. You may harvest it.')
        else
          # TODO: Find Excel and write a .from_excel method much like .from_xml...
          fail_with("DropDir: New Resource (#{dir}), but no meta.xml. Cannot proceed!") unless
            File.exist?("#{dir}/meta.xml")
          @resource.re_read_xml
        end
      end
      @resource
    end

    def noko_parse(url)
      require 'open-uri'
      begin
        # TODO: we should probably move this to Net::HTTP.open or URI.open, which is more secure. Or just use wget.
        raw = open(url)
      rescue Net::ReadTimeout => e
        fail_with(e.message)
      end
      fail_with('URL returned empty result.') if raw.blank?
      Nokogiri::HTML(raw)
    end

    def create_resource(noko)
      name = strip_string(noko.css('h1')&.first&.text)
      # Lots of names are super-lame. In those cases, let's just re-use the partner name:
      name = strip_string(noko.css('.breadcrumb li a')[-2].text) if name.match?(/resource/i)
      abbr = abbreviate(name)
      desc = noko.css('.prose p,blockquote').map(&:text).map { |txt| strip_string(txt) }.join("\n")
      @resource = Resource.create(name: name, abbr: abbr, description: desc, notes: 'auto-harvested, requires editing.',
                                  opendata_url: @url)
      FileUtils.mkdir_p(@resource.path) unless Dir.exist?(@resource.path)
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
      @resource.fake_partner unless @partner # (it may have failed)
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
        # TODO: we should probably move this to Net::HTTP.open or URI.open, which is more secure. Or just use wget.
        open(link, 'rb') do |input|
          file.write(input.read)
        end
      end
      raise('Did not download') unless File.exist?(path) && File.size(path).positive?

      path
    end

    def strip_string(str)
      str.gsub(/\s*\(\d+\)\s*/m, ' ').gsub(/\W+/m, ' ').gsub(/^\s+/m, '').gsub(/\s+$/m, '')
    end

    def abbreviate(name)
      return name.gsub(/\s+/, '_').downcase if name.size < 8

      # NOTE: the #titleize helps split CamelCase stuff.
      words = name.titleize.split.map(&:downcase)
      words.delete_if { |w| @stopwords.include?(w) }
      words = words.map { |word| use_abbr(word, name) }
      abbr = if words.size > 4
               words.map(&:first).join # We make it an acronym (without underscores)
             elsif words.size > 1
               words.join('_')
             else
               name
             end
      abbr = abbr.gsub(/\s+/, '_').downcase[0..15]
      ensure_unique(abbr)
    end

    def ensure_unique(abbr)
      counter = 1
      while Resource.where(abbr: abbr).exists?
        counter += 1
        c_str = counter.to_s
        abbr_len = 15 - c_str.size
        abbr = "#{abbr[0..abbr_len]}#{c_str}"
      end
      abbr
    end

    def use_abbr(word, name)
      return name if name.match?(/#{word.upcase}/) # Acroynm; keep as-is.

      sym = word.to_sym
      @abbreviations.key?(sym) ? @abbreviations[sym] : word
    end

    def shorten(name)
      return name if name.size < 8

      words = name.split
      return words[0..1] if words.size > 4

      return name.sub(/[^A-Z]/, '') if name.sub(/[^A-Z]/, '').size >= 3

      name[0..15]
    end

    def fail_with(message)
      e = Exception.new(message)
      @process.fail(e)
      raise e
    end
  end
end
