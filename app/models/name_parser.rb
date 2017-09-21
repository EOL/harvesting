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
    @names_file = Rails.root.join('tmp', "names_from_harvest_#{@harvest.id}.txt")
  end

  def parse
    loop_over_names_in_batches do |names|
      @names = {}
      write_names_to_file(names)
      learn_names(names)
      JSON.parse(parse_names_in_file).each_with_index do |result, i|
        # NOTE: interestingly, this skips running a SQL update if nothing changed, and, when only some fields change, it
        # only updates those fields (not the ones that stay the same). Thanks, Rails. ...That said, it's damn slow.
        # ...And aside from re-inserting them with an "on existing update" thingie, I'm not sure how to speed this up.
        # Sigh.
        debugger unless @names.key?(result['verbatim'])
        begin
          @names[result['verbatim']].update_attributes(parse_result(result))
        rescue => e
          puts "error reading line #{i}"
          debugger
          puts 'shoot.'
        end
      end
    end
  end

  def loop_over_names_in_batches
    ScientificName.where(harvest_id: @harvest.id).select('id, verbatim').find_in_batches(batch_size: 10_000) do |names|
      yield(names)
    end
  end

  def write_names_to_file(names)
    @verbatims = names.map(&:verbatim).join("\n") + "\n"
    File.unlink(@names_file) if File.exist?(@names_file)
    File.open(@names_file, 'a') { |file| file.write(@verbatims) }
  end

  def learn_names(names)
    names.each { |name| @names[name.verbatim] = name }
  end

  def parse_names_in_file
    outfile = Rails.root.join('tmp', "names-parsed-#{@resource.id}.json")
    File.unlink(outfile) if File.exist?(outfile)
    stdin, stdout, stderr, wait_thread = Open3.popen3("gnparse file --input #{@names_file} "\
      "--output #{outfile}")
    stdin.close
    stdout.close
    stderr.close
    status = wait_thread.value
    # TODO something with status TODO: DO SOMETHING WITH stdout/stderr ... expect err to be nil, expect out to be
    # something like "running with parallelism: 12\n" NOTE: it's a little awkward in that the output is one-per-line,
    # rather than the whole file actually being json. We force it into an array syntax:
    json = "[" + File.read(outfile).gsub("\n", ",").chop + "]"
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
              debugger unless i.is_a?(Hash)
              add_authorship(authorships, i)
            end
          else
            debugger unless v.is_a?(Hash)
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
      warns = "UNPARSED"
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

    return attributes.merge(
      normalized: norm,
      canonical: canon,
      authorship: authorships.join(' ; '),
      warnings: warns,
      parse_quality: quality,
      year: authorships.map { |a| a[:year] }.compact.sort.first # Yeeesh! We take the earliest year (we only get one!)
    )
  end

  def add_authorship(authorships, hash)
    hash ||= {}
    if hash.key?('authorship')
      value = hash['authorship']['value']
      if hash['authorship'].key?('basionym_authorship')
        first = hash['authorship']['basionym_authorship']['authors'].first # We only need one for et. al
        year = hash['authorship']['basionym_authorship']['year']['value'] if
          hash['authorship']['basionym_authorship'].key?('year')
      end
    end
    authorships << { value: value, first_author: first, year: year }
  end
end
