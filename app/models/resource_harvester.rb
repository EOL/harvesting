require "open3"

class ResourceHarvester
  attr_accessor :resource, :harvest

  # NOTE: I'll make this "classy" later; for now I just want to read in our test
  # file and "feel out" how the class should actually work.
  def initialize(resource)
    @resource = resource
    @harvest = nil
    @uris = {}
    @formats = {}
  end

  def start
    create_harvest_instance
    fetch
    validate
    # TODO delta
    store
    check_consistency
    # TODO queue_downloads
    parse_names
    match_nodes
    build_ancestry
    normalize_units
    # TODO link
    # TODO index_and_calculate_statistics
    complete_harvest_instance
  end

  def create_harvest_instance
    @harvest = @resource.create_harvest_instance
  end

  # grab the file from each format
  def fetch
    @harvest.formats.each do |fmt|
      # TODO ... I don't care right now. :)
      fmt.file = fmt.get_from
    end
  end

  def each_format(&block)
    @harvest.formats.each do |fmt|
      fid = fmt.id
      unless @formats.has_key?(fid)
        @formats[fid] = {}
        @formats[fid][:parser] = if fmt.excel?
            ExcelParser.new(fmt.file, sheet: fmt.sheet,
              header_lines: fmt.header_lines,
              data_begins_on_line: fmt.data_begins_on_line)
          elsif fmt.csv?
            CsvParser.new(fmt.file, field_sep: fmt.field_sep,
              line_sep: fmt.line_sep, header_lines: fmt.header_lines,
              data_begins_on_line: fmt.data_begins_on_line)
          else
            raise "I don't know how to read formats of #{fmt.file_type}!"
          end
        @formats[fid][:headers] = @formats[fid][:parser].headers
      end
      yield(fmt, @formats[fid][:parser], @formats[fid][:headers])
    end
  end

  # validate each file; stop on errors, log warnings...
  def validate
    each_format do |fmt, parser, headers|
      fields = {}
      expected_by_file = headers.dup
      fmt.fields.each_with_index do |field, i|
        raise Exceptions::ColumnMissing.new(field.expected_header) if
          headers[i].nil?
        raise Exceptions::ColumnMismatch.new("expected '#{field.expected_header}' as column #{i}, but got '#{headers[i]}'") unless
          field.expected_header == headers[i]
        fields[headers[i]] = field
        expected_by_file.delete(headers[i])
      end
      raise Exceptions::ColumnUnmatched.new(expected_by_file.join(",")) if
        expected_by_file.size > 0
      parser.rows_as_hashes do |row, line|
        headers.each do |header|
          check = fields[header]
          next unless check
          val = row[header]
          if val.blank?
            next if check.can_be_empty?
            fmt.warn("Illegal empty value for #{header}", line)
          end
          if check.must_be_integers?
            unless row[header] =~ /\a[\d,]+\z/m
              fmt.warn("Illegal non-integer for #{header}, got #{val}", line)
            end
          elsif check.must_know_uris?
            unless uri_exists?(val)
              fmt.warn("Illegal unknown URI <#{val}> for #{header}", line)
            end
          end
        end
      end
    end
  end

  def uri_exists?(uri)
    return true if @uris.has_key?(uri)
    if Term.where(uri: uri).exists?
      @uris[uri] = true
    else
      false
    end
  end

  # check for deltas from previous harvests (if any)
  def delta
    # TODO: I don't want to tackle this on the first pass; I will come back to
    # it.
    raise "Unimplemented"
  end

  # read the raw new/updated data into the database, TODO: log curation conflicts
  def store
    # Recall these are in a specific order (and need to be). The assumption here
    # is that the file describing the nodes MUST be first. (It MUST be.)
    @nodes = {}
    @ancestors = {}
    each_format do |fmt, parser, headers|
      fields = build_fields(fmt, headers)
      parser.rows_as_hashes do |row, line|
        @models = { node: nil, parent_node: nil, scientific_name: nil,
          ancestors: [] }
        begin
          headers.each do |header|
            field = fields[header]
            send(field.mapping, field, row[header]) unless row[header].blank?
          end
        rescue => e
          puts "Failed to parse row #{line}..."
          debugger
          raise e
        end
        begin
          if @models[:scientific_name]
            @models[:scientific_name].resource_id = @resource.id
            @models[:scientific_name].save!
            @models[:node].scientific_name_id =
              @models[:scientific_name].id if @models[:node]
          end
          if @models[:parent_node]
            @models[:parent_node].resource_id = @resource.id
            @models[:parent_node].save!
            @models[:node].parent_id = @models[:parent_node].id if
              @models[:node]
          end
          if @models[:node]
            @models[:node].resource_id = @resource.id
            @nodes[@models[:node].resource_pk] = @models[:node].save!
            @models[:scientific_name].update_attribute(:node_id,
              @models[:node].id) if @models[:scientific_name]
          end
          unless @models[:ancestors].empty?
            parent_id = 0
            @models[:ancestors].each do |ancestor|
              if ancestor[:node].new_record?
                ancestor[:sci_name].save!
                ancestor[:node].scientific_name_id = ancestor[:sci_name].id
                ancestor[:node].parent_id = parent_id
                ancestor[:node].save!
                @ancestors[ancestor[:name]] = ancestor
              end
              parent_id = ancestor[:node].id
            end
            if @models[:parent_node]
              @models[:parent_node].update_attribute(:parent_id, parent_id)
            else
              @models[:node].update_attribute(:parent_id, parent_id)
            end
          end
        rescue => e
          if row.values.compact.size < (row.values.size / 5)
            fmt.warn("Empty row?", line)
          else
            puts "Failed to save data from row #{line}..."
            debugger
            raise e
          end
        end
      end
    end
  end

  # TODO: Move things around...
  def to_nodes_pk(field, val)
    @models[:node] ||= Node.new
    @models[:node].resource_pk = val
  end
  def to_nodes_scientific(field, val)
    @models[:node] ||= Node.new
    @models[:scientific_name] ||= ScientificName.new
    @models[:scientific_name].verbatim = val
    @models[:node].name_verbatim = val
  end
  def to_nodes_parent_fk(field, val)
    @models[:node] ||= Node.new
    @models[:parent_node] ||= Node.new
    @models[:parent_node].resource_pk = val
  end
  def to_nodes_ancestor(field, val)
    if @ancestors[val]
      @models[:ancestors] << {
        name: val,
        sci_name: @ancestors[val][:sci_name],
        node: @ancestors[val][:node]
      }
    else
      @models[:ancestors] << {
        name: val,
        sci_name: ScientificName.new(verbatim: val, resource_id: @resource.id),
        node: Node.new(rank_verbatim: field.submapping,
          resource_id: @resource.id, name_verbatim: val)
      }
    end
  end
  def to_nodes_rank(field, val)
    @models[:node] ||= Node.new
    @models[:node].rank_verbatim = val
  end
  def to_nodes_further_information_url(field, val)
    @models[:node] ||= Node.new
    @models[:node].further_information_url = val
  end
  def to_taxonomic_status(field, val)
    @models[:scientific_name] ||= ScientificName.new
    @models[:scientific_name].taxonomic_status_verbatim = val
  end
  def to_nodes_remarks(field, val)
    @models[:node] ||= Node.new
    @models[:node].remarks = val
  end
  def to_nodes_publication(field, val)
    @models[:scientific_name] ||= ScientificName.new
    @models[:scientific_name].publication = val
  end
  def to_nodes_source_reference(field, val)
    @models[:scientific_name] ||= ScientificName.new
    @models[:scientific_name].source_reference = val
  end

  def build_fields(fmt, headers)
    fields = {}
    fmt.fields.each_with_index do |field, i|
      fields[headers[i]] = field
    end
    fields
  end

  def check_consistency
  end

  def queue_downloads
  end

  # TODO: cleanup, test
  def parse_names
    # NOTE: we may change the way we do this, from using a file of names to
    # calling a service, but for now, this will work fine and should be pretty
    # scalable. THAT said, TODO is that we don't want all of the names from the
    # resource, we only want the "new" ones (that is, new or modified). Perhaps
    # we can achieve that with a timestamp. but for now, I'm ignoring it, since
    # we don't have delta-detection, yet.
    names = ScientificName.where(resource_id: @resource.id)
    verbatims = names.pluck(:verbatim).join("\n")
    filename = Rails.root.join("tmp", "names-#{@resource.id}.txt")
    File.unlink(filename)
    outfile = Rails.root.join("tmp", "names-parsed-#{@resource.id}.json")
    File.unlink(outfile)
    File.open(filename, "w") { |file| file.write(verbatims) }
    _, stdout, stderr = Open3.popen3("gnparse file --input #{filename} "\
      "--output #{outfile}")
    # TODO: DO SOMETHING WITH stdout/stderr ... ecpect err to be nil, expect out
    # to be something like "running with parallelism: 12\n" NOTE: it's a little
    # awkward in that the output is one-per-line, rather than the whole file
    # actually being json. We force it into an array syntax:
    json = "[" + File.read(outfile).gsub("\n", ",").chop + "]"
    JSON.parse(json).each do |result|
      # Examples: https://github.com/GlobalNamesArchitecture/gnparser/blob/master/parser/src/test/resources/test_data.txt
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

      # NOTE: interestingly, this skips updating if nothing changed, and only
      # changes fields that actually did get a change. Thanks, Rails.  ...That
      # said, it's damn slow.
      names.find { |n| n.verbatim == result["verbatim"] }.update_attributes(
        warnings: warns,
        genus: genus,
        specific_epithet: epi,
        authorship: authors,
        parse_quality: result["quality"]
      )
    end
  end

  # match node names against the DWH, store "hints", report on unmatched
  # nodes, consider the effects of curation
  def match_nodes
  end

  # store ancestry for objects (so we know which pages are affected)
  def build_ancestry
  end

  def normalize_units
  end

  # add links and build links to DOI and the like (and find missing DOIs)
  def link
  end

  # index and update statistics
  def index_and_calculate_statistics
  end

  # send notifications and finish up the instance:
  def complete_harvest_instance
    @harvest.update_attribute(:completed_at, Time.now)
  end
end
