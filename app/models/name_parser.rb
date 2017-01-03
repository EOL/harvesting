class NameParser
  def self.for_resrouce(resource)
    parser = NameParser.new(resource)
    parser.parse
  end

  def initialize(resource)
    @resource = resource
  end

  def parse
    # NOTE: we may change the way we do this, from using a file of names to
    # calling a service, but for now, this will work fine and should be pretty
    # scalable. THAT said, TODO is that we don't want all of the names from the
    # resource, we only want the "new" ones (that is, new or modified). Perhaps
    # we can achieve that with a timestamp. but for now, I'm ignoring it, since
    # we don't have delta-detection, yet.
    names = ScientificName.where(resource_id: @resource.id)
    filename = write_names_to_file(names)
    outfile = parse_names_in_file(filename)
    JSON.parse(json).each do |result|
      # NOTE: interestingly, this skips running a SQL update if nothing changed,
      # and, when only some fields change, it only updates those fields (not the
      # ones that stay the same). Thanks, Rails. ...That said, it's damn slow:
      names.find { |n| n.verbatim == result["verbatim"] }.
        update_attributes(parse_result(result))
    end

    def write_names_to_file(names)
      verbatims = names.pluck(:verbatim).join("\n")
      filename = Rails.root.join("tmp", "names-#{@resource.id}.txt")
      File.unlink(filename)
      filename
    end

    def parse_names_in_file(filename)
      Rails.root.join("tmp", "names-parsed-#{@resource.id}.json")
      File.unlink(outfile)
      File.open(filename, "w") { |file| file.write(verbatims) }
      _, stdout, stderr = Open3.popen3("gnparse file --input #{filename} "\
        "--output #{outfile}")
      # TODO: DO SOMETHING WITH stdout/stderr ... ecpect err to be nil, expect out
      # to be something like "running with parallelism: 12\n" NOTE: it's a little
      # awkward in that the output is one-per-line, rather than the whole file
      # actually being json. We force it into an array syntax:
      json = "[" + File.read(outfile).gsub("\n", ",").chop + "]"
    end

    # Examples of the types of results you will get may be found here:
    # https://github.com/GlobalNamesArchitecture/gnparser/blob/master/parser/src/test/resources/test_data.txt
    def parse_result(result)
      genus = nil
      epi = nil
      authors = nil
      if result.has_key?("details")
        result["details"].each do |hash|
          hash.each do |k, v|
            case k
            when "genus"
              genus = v["value"]
            when "specific_epithet"
              epi = v["value"]
              if v.has_key?("authorship")
                authors = v["authorship"]["value"]
              end
            end
          end
        end
      end
      warns = result.has_key?("quality_warnings") ?
        result["quality_warnings"].map { |a| a[1] }.join("; ") :
        nil
      quality = result["quality"] ? result["quality"].to_i : 0
      return {
        genus: genus,
        specific_epithet: epi,
        authorship: authors,
        warnings: warns,
        parse_quality: quality
      }
    end
  end
end
