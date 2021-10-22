# Parses names using the GNA system, via open3 system call.
require 'net/http' # I DO NOT KNOW WHY WE NEED THIS. But as of Feb 2020, we do?

class NameParser
  def self.for_harvest(harvest, process)
    parser = NameParser.new(harvest, process)
    parser.parse
  end

  def self.parse_names(harvest, names)
    process = LoggedProcess.new(harvest.resource)
    begin
      process.run_step('parse_names') do
        parser = NameParser.new(harvest, process)
        parser.run_parser_on_names(names)
      end
      harvest.complete
    rescue => e
      process.fail(e)
      harvest.fail
      raise e
    ensure
      process.exit
    end
  end

  def initialize(harvest, process)
    @harvest = harvest
    @process = process
    @resource = harvest&.resource
    @verbatims = []
  end

  def parse
    @attempts = 0
    # NOTE: this while loop is ONLY here because gnparser seems to skip some names in each batch. For about 24K names,
    # it misses 20. For 20, it misses 1. I'm still not sure why, but rather than dig further, I'm using this workaround.
    # Ick. TODO: find the problem and fix.
    count = ScientificName.where(harvest_id: @harvest.id).count
    count = ScientificName.where(harvest_id: @harvest.id, canonical: nil).count
    min_count_diff = 2
    previous_count = count + min_count_diff + 1 # This just fakes a pass the first time...
    while (count = ScientificName.where(harvest_id: @harvest.id, canonical: nil).count) && count.positive?
      if count >= previous_count - min_count_diff
        @process.warn("Failed to parse enough new names (#{@attempts} attempts), stopping...")
        break
      end
      previous_count = count
      @process.warn("I see #{count} names which still need to be parsed.")
      @attempts += 1
      # For debugging help:
      # names = ScientificName.where(harvest_id: @harvest.id, canonical: nil).limit(100)
      loop_over_names_in_batches do |names|
        @names = {}
        @verbatims = names.map(&:verbatim)
        learn_names(names) # populates @names
        json = run_parser_on_names(@verbatims)
        updates = []
        begin
          parsed = JSON.parse(json)
          if !parsed.is_a?(Array)
            if parsed.has_key?('message')
              @process.warn(parsed['message'])
            else
              @process.warn("Cannot parse result of GNParser query: #{parsed[0..4000]}")
            end
            raise "Bad result from GN Parser!"
          end
          @process.warn("Names to parse: #{names.size} formatted: #{@verbatims.size} learned: #{@names.size} parsed: #{parsed.size}")
          parsed.each_with_index do |result, i|
            verbatim = result['verbatim'].gsub(/^\s+/, '').gsub(/\s+$/, '')
            if @names[verbatim].nil? || @names[verbatim].empty?
              @process.warn("skipping assigning name to #{verbatim} (missing!): #{result.inspect}")
              next
            end
            begin
              @names[verbatim].each do |name|
                name.assign_attributes(parse_result(result))
              end
              updates += @names[verbatim]
            rescue => e
              @process.warn("ERROR reading line #{i}: #{result[0..250]}")
              @process.warn("ERROR on verbatim: #{verbatim}") if verbatim
              raise(e)
            end
          end
        rescue JSON::ParserError => e
          file = @harvest.resource.path.join('failed_names.json')
          File.unlink(file) if File.exist?(file)
          File.open(file, 'w') { |out| out.write(json) }
          error_limit = 10_000 # The size at which we notice it is probably spitting back the WHOLE RESPONSE.
          bad_server = e.message.size > error_limit
          message = bad_server ? "#{e.message[0..error_limit]}[snip]..." : e.message
          @process.warn("Failed to parse JSON: #{message}")
          @process.warn("Re-try with:  JSON.parse(File.read('#{file}'))")
          raise('LOOKS LIKE GN SERVER IS NOT WORKING, please check!') if bad_server # It's all gone bad!
        end
        update_names(updates) unless updates.empty?
      end
      sleep(1)
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

  def learn_names(names)
    names.each do |name|
      clean_name = name.verbatim.gsub(/^\s+/, '').gsub(/\s+$/, '')
      @names[clean_name] ||= []
      @names[clean_name] << name
    end
  end

  def request_parser(body)
    uri = URI('https://parser.globalnames.org/api/v1/') # NOTE: the trailing slash IS required
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
    request_parser({names: Array(verbatims), withDetails: true}.to_json)
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
      result['details'].each do |detail_type, value|
        # We can't parse these, because the results get confusing (there is more than one of each), and we don't do
        # anything with them anyway.
        next if detail_type == 'hybridFormula'
        if value.is_a?(Hash)
          value.each do |k, v|
            next if v.nil? # specific_epithet seems to do this occassionally and I don't know why. :|
            k = k.underscore.downcase # Looks like the format changed from this_style to thisStyle; change it back!
            next if k == 'annotation_identification'
            next if k == 'ignored'
            if k == 'infraspecific_epithets'
              attributes['infraspecific_epithet'] = v.map { |i| i['value'] }.join(' ; ')
              v.each do |i|
                add_authorship(authorships, i)
              end
            else
              if v.is_a?(Hash)
                add_authorship(authorships, v)
              elsif ScientificName.attribute_names.include?(k)
                attributes[k] = v['value']
              end
            end
          end
        end
      end
    end
    if result.key?('canonical')
      canonical = result['canonical']
      canon =
        if canonical.key?('simple')
          canonical['simple']
        elsif canonical.key?('stemmed')
          canonical['stemmed']
        elsif canonical.key?('full')
          canonical['full']
        end
    end
    if result['parsed']
      warns = if result.key?('qualityWarnings')
        result['qualityWarnings'].map { |w| w['warning'] }.join('|')
      else
        ''
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
