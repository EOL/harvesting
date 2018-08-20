require 'open3'

# Parses names using the GNA system, via open3 system call.
class NameParser
  def self.for_harvest(harvest)
    parser = NameParser.new(harvest)
    parser.parse
  end

  def initialize(harvest)
    @harvest = harvest
    @resource = harvest.resource
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
        write_names_to_file(names)
        learn_names(names)
        json = parse_names_in_file
        updates = []
        JSON.parse(json).each_with_index do |result, i|
          begin
            @names[result['verbatim']].assign_attributes(parse_result(result))
            updates << @names[result['verbatim']]
          rescue => e
            @harvest.log("error reading line #{i}", cat: :errors)
            raise(e)
          end
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

  def write_names_to_file(names)
    @verbatims_size = names.size
    @verbatims = names.map(&:verbatim).join("\n") + "\n"
  end

  def learn_names(names)
    names.each do |name|
      clean_name = name.verbatim.gsub(/^\s+/, '').gsub(/\s+$/, '')
      @names[clean_name] = name
    end
  end

  def parse_names_in_file
    # TODO: the command should be config'd, so we can move it around as needed. Eventually we'll use a service.
    cmd = 'gnparser'
    json = []
    Open3.popen3(cmd) do |stdin, stdout, _, wait_thread|
      stdin.write(@verbatims)
      stdin.close_write
      # TODO: I think I'm missing the first one. ...or the last one...
      while (line = stdout.gets)
        json << line.chomp if line =~ /^{/
      end
      exit_status = wait_thread.value
      abort "!! FAILED #{cmd}" unless exit_status.success?
    end
    if @verbatims_size != json.size
      @harvest.log("Found #{@verbatims_size} verbatims from #{json.size} results", cat: :warns)
    end
    "[#{json.join(',')}]"
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
          next if k == 'annotation_identification'
          next if k == 'ignored'
          if k == 'infraspecific_epithets'
            attributes['infraspecific_epithet'] = v.map { |i| i['value'] }.join(' ; ')
            v.each do |i|
              add_authorship(authorships, i)
            end
          else
            attributes[k] = v['value']
            add_authorship(authorships, v)
          end
        end
      end
    end
    if result.key?('canonical_name')
      canonical = result['canonical_name']
      canon =
        if canonical.is_a?(String)
          canonical
        elsif canonical.is_a?(Hash)
          if canonical.key?('value')
            canonical['value']
          elsif canonical.key?('extended')
            canonical['extended']
          end
        end
    end
    if result['parsed']
      warns = result.key?('quality_warnings') ? result['quality_warnings'].map { |a| a[1] }.join('; ') : nil
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
      if hash['authorship'].key?('basionym_authorship')
        authors = hash['authorship']['basionym_authorship']['authors']
        first = authors.first # We only need one for et. al
        year = hash['authorship']['basionym_authorship']['year']['value'] if
          hash['authorship']['basionym_authorship'].key?('year')
      end
    end
    authorships << { value: value, first_author: first, year: year, authors: authors }
  end
end
