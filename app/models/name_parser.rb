# Parses names using the GNA system, via open3 system call.
class NameParser
  def self.for_harvest(harvest)
    parser = NameParser.new(harvest)
    parser.parse
  end

  def self.parse_names(names)
    parser = NameParser.new(nil)
    parser.run_parser_on_names(names)
  end

  def initialize(harvest)
    @harvest = harvest
    @resource = harvest&.resource
    @verbatims = []
  end

  def parse
    @attempts = 0
    # NOTE: this while loop is ONLY here because gnparser seems to skip some names in each batch. For about 24K names,
    # it misses 20. For 20, it misses 1. I'm still not sure why, but rather than dig further, I'm using this workaround.
    # Ick. TODO: find the problem and fix.
    count = 0 # scope
    while (count = ScientificName.where(harvest_id: @harvest.id, canonical: nil).count) && count.positive? && @attempts <= 10
      @harvest.log("I see #{count} names which still need to be parsed.", cat: :warns)
      @attempts += 1
      # For debugging help:
      # names = ScientificName.where(harvest_id: @harvest.id, canonical: nil).limit(100)
      loop_over_names_in_batches do |names|
        @names = {}
        format_names(names)
        learn_names(names)
        json = run_parser_on_names(@verbatims)
        updates = []
        begin
          parsed = JSON.parse(json)
          parsed = parsed['namesJson'] if parsed.is_a?(Hash) && parsed.key?('namesJson')
          parsed.each_with_index do |result, i|
            verbatim = result['verbatim'].gsub(/^\s+/, '').gsub(/\s+$/, '')
            if @names[verbatim].nil?
              @harvest.log("error assigning name to #{verbatim} (missing!): #{result.inspect}", cat: :errors)
              next
            end
            begin
              @names[verbatim].assign_attributes(parse_result(result))
              updates << @names[verbatim]
            rescue => e
              @harvest.log("error reading line #{i}: #{result[0..250]}", cat: :errors)
              raise(e)
            end
          end
        rescue JSON::ParserError => e
          file = @harvest.resource.path.join('failed_names.json')
          File.unlink(file) if File.exist?(file)
          File.open(file, 'w') { |out| out.write(json) }
          @harvest.log("Failed to parse JSON: #{e} OUTPUT: #{file}", cat: :errors)
        end
        update_names(updates) unless updates.empty?
      end
      sleep(1)
    end
    if @attempts >= 20 && count > 100
      @harvest.log('Required more than 10 attempts to parse all names!', cat: :errors)
      raise 'Too many attempts to parse names'
    end
  end

  def update_names(updates)
    ScientificName.import(
      updates,
      on_duplicate_key_update:
        %i[authorship canonical genus hybrid infrageneric_epithet infraspecific_epithet normalized parse_quality
           publication remarks specific_epithet surrogate uninomial verbatim virus warnings year]
    )
  end

  def loop_over_names_in_batches
    # NOTE: gnparser is skipping about 20 lines (out of 24K or so). I don't know why.
    ScientificName.where(harvest_id: @harvest.id, canonical: nil).find_in_batches(batch_size: 10_000) do |names|
      yield(names)
    end
  end

  def format_names(names)
    @verbatims_size = names.size
    # @verbatims = names.map(&:verbatim).join("\n") + "\n" # OLD VERSION, where parser took string...
    # New version, where parser takes JSON:
    @verbatims = names.map(&:verbatim)
  end

  def learn_names(names)
    names.each do |name|
      clean_name = name.verbatim.gsub(/^\s+/, '').gsub(/\s+$/, '')
      @names[clean_name] = name
    end
  end

  def request_parser(body)
    uri = URI('https://parser.globalnames.org/api')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'accept' => 'json')
    request.body = body
    response = http.request(request)
    response.body.force_encoding('UTF-8')
  end

  def ping_parser
    response = request_parser('')
    raise "GN Parser unavailble: #{response}" unless response.match?(/^\[\]/)
  end

  def run_parser_on_names(verbatims)
    request_parser(Array(verbatims).to_json)
  end

  # Examples of the types of results you will get may be found by doing:
  # js = JSON.parse(File.read(Rails.root + "doc/names_parser_test_data.json"))

  def parse_result(result)
    genus = nil
    spec = nil
    infra_sp = nil
    infra_g = nil
    authorships = []
    uni = nil
    attributes = {}
    warns = nil
    quality = 0
    norm = nil
    if result.key?('details')
      result['details'].each do |hash|
        hash.each do |k, v|
          k = k.underscore.downcase # Looks like the format changed from this_style to thisStyle; change it back!
          next if k == 'annotation_identification'
          next if k == 'ignored'
          if k == 'infraspecific_epithets'
            attributes['infraspecific_epithet'] = v.map { |i| i['value'] }.join(' ; ')
            v.each do |i|
              add_authorship(authorships, i)
            end
          else
            begin
              attributes[k] = v['value']
            rescue => e
              @harvest.log("ERROR: no '#{k}' value for attributes: #{v.inspect}", cat: :errors)
              raise e
            end
            add_authorship(authorships, v)
          end
        end
      end
    end
    if result.key?('canonicalName')
      canonical = result['canonicalName']
      canon =
        if canonical.is_a?(String)
          canonical
        elsif canonical.is_a?(Hash)
          if canonical.key?('valueRanked')
            canonical['valueRanked']
          elsif canonical.key?('value')
            canonical['value']
          elsif canonical.key?('extended')
            canonical['extended']
          elsif canonical.key?('simple')
            canonical['simple']
          elsif canonical.key?('full')
            canonical['full']
          end
        end
    end
    if result['parsed']
      warns = if result.key?('qualityWarnings')
        result['qualityWarnings'].map { |a| a[1] }.join('; ')
      end
      quality = result['quality'] ? result['quality'].to_i : 0
      norm = result['normalized'] ? result['normalized'] : nil
    else
      warns = 'UNPARSED'
      quality = 0
      canon = result['verbatim']
    end
    norm = result['verbatim'] if norm.blank?
    if norm.size > 250
      norm = canon
      authorships.each do |authorship|
        norm += " #{authorship[:first]}, et. al"
        norm += " #{authorship[:year]}" if authorship[:year]
      end
      norm = norm[0..249] if norm.size > 250 # Forced to simply truncate it if we couldn't parse it.
    end
    norm = result['verbatim'] if norm.blank?

    attributes.merge(
      normalized: norm,
      canonical: canon,
      authorship: authorships.flat_map { |a| a[:authors].blank? ? [] : a[:authors].map { |n| n&.tr(';', '|') } }.join('; '),
      warnings: warns,
      parse_quality: quality,
      year: authorships.map { |a| a[:year] }.compact.sort.first # Yeeesh! We take the earliest year (we only get one!)
    )
  end

  def add_authorship(authorships, hash)
    value = nil
    first = nil
    year = nil
    authors = nil
    hash ||= {}
    if hash.key?('authorship')
      value = hash['authorship']['value']
      if hash['authorship'].key?('basionymAuthorship')
        authors = hash['authorship']['basionymAuthorship']['authors']
        first = authors.first # We only need one for et. al
        year = hash['authorship']['basionymAuthorship']['year']['value'] if
          hash['authorship']['basionymAuthorship'].key?('year')
      end
    end
    authorships << { value: value, first_author: first, year: year, authors: authors }
  end
end
