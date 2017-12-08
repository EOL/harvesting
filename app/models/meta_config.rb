# Read a meta.xml config file and create the resource file formats.
class MetaConfig
  attr_accessor :resource, :path, :doc

  def self.import(path, resource = nil)
    new(path, resource).import
  end

  def self.analyze
    hashes = {}
    Resource.find_each do |resource|
      format = resource.formats.last
      filename = format.get_from
      basename = File.basename(filename)
      filename = filename.sub(basename, 'meta.xml')
      unless File.exist?(filename)
        # puts "SKIPPING missing meta file for format: #{format.id}"
        next
      end
      @doc = File.open(filename) { |f| Nokogiri::XML(f) }
      tables = @doc.css('archive table')
      tables.each do |table|
        location = table.css("files location").first.text
        puts "++ #{resource.name}/#{location}"
        table.css('field').each do |field|
          i = field['index'].to_i
          format = resource.formats.where("get_from LIKE '%#{location}'")&.first
          if format.nil?
            # puts "SKIPPING missing format for #{location}"
            next
          end
          db_field = format.fields[i]
          if db_field.nil?
            # puts "SKIPPING missing db field for format #{format.id}..."
            next
          end
          key = "#{field['term']}/#{format.represents}"
          if hashes.key? key
            if hashes[key][:represents] == "to_ignored"
              # puts ".. It was ignored; overriding..."
            elsif hashes[key][:represents] == db_field.mapping
              next
            else
              puts "!! I'm leaving the old value for #{key} of #{hashes[key][:represents]} and losing the value "\
                "of #{db_field.mapping}"
              next
            end
          end
          hashes[key] = {
            term: field['term'],
            for_format: format.represents,
            represents: db_field.mapping,
            submapping: db_field.submapping,
            is_unique: db_field.unique_in_format,
            is_required: !db_field.can_be_empty
          }
        end
      end
    end
    File.open(Rails.root.join('db', 'data', 'meta_analyzed.json'),"w") do |f|
      f.write(hashes.values.sort_by { |h| h[:term] }.to_json.gsub(/,/, ",\n"))
    end
    puts "Done. Created #{hashes.keys.size} hashes."
  end

  def initialize(path, resource = nil)
    @path = path
    @resource = resource || Resource.create
  end

  def import
    @resource.formats.delete_all
    filename = "#{@path}/meta.xml"
    return 'Missing meta.xml file' unless File.exist?(filename)
    @doc = File.open(filename) { |f| Nokogiri::XML(f) }
    tables = @doc.css('archive table')
    ignored_fields = []
    formats = []
    tables.each do |table|
      table_name = table.css("files location").text
      raise "No headers: #{table_name.downcase} #{filename}" if table['ignoreHeaderLines'].to_i.zero?
      table_file = "#{@path}/#{table_name}"
      unless File.exist?(table_file)
        puts "!! SKIPPING missing file: #{table_file}"
        next
      end
      # TODO: :attributions, :articles, :images, :js_maps, :links, :maps, :sounds, :videos
      reps =
        case table['rowType']
        when "http://rs.tdwg.org/dwc/terms/Taxon"
          :nodes
        when "http://rs.tdwg.org/dwc/terms/Occurrence"
          :occurrences
        when "http://rs.tdwg.org/dwc/terms/MeasurementOrFact"
          :measurements
        when "http://eol.org/schema/reference/Reference"
          :refs
        when "http://eol.org/schema/agent/Agent"
          :agents
        when "http://eol.org/schema/media/Document"
          :media
        when "http://rs.gbif.org/terms/1.0/VernacularName"
          :vernaculars
        when "http://eol.org/schema/Association"
          :assocs
        when "http://rs.tdwg.org/dwc/terms/Event"
          :skip
        end
      if reps == :skip
        puts "SKIPPING events file..."
        next
      end
      reps ||=
        case table_name.downcase
        when /^agent/
          :agents
        when /^tax/
          :nodes
        when /^ref/
          :refs
        when /^med/
          :media
        when /^(vern|common)/
          :vernaculars
        when /occurr/
          :occurrences
        when /assoc/
          :assocs
        when /(measurement|data|fact)/
          :measurements
        when /^events/
        else
          raise "I cannot determine what #{table_name} represents!"
        end
      sep = table['fieldsTerminatedBy']
      sep = "\t" if sep == "\\t"
      fmt = Format.create!(
        resource_id: @resource.id,
        harvest_id: nil,
        header_lines: table['ignoreHeaderLines'],
        data_begins_on_line: table['ignoreHeaderLines'],
        file_type: :csv,
        represents: reps,
        get_from: "#{@path}/#{table_name}",
        field_sep: sep,
        line_sep: table['linesTerminatedBy'],
        utf8: table['encoding'] =~ /^UTF/
      )
      headers = `head -n #{table['ignoreHeaderLines']} #{table_file.gsub(' ', '\\ ')}`.split(sep)
      headers.last.chomp!
      fields = []
      table.css('field').each do |field|
        assumption = MetaXmlField.where(term: field['term'], for_format: reps)&.first
        a_submap = assumption&.submapping
        a_submap = nil if a_submap == '0'
        mapping_name = assumption&.represents || :to_ignored
        index = field['index'].to_i
        header_name = headers[index]
        if mapping_name == 'to_nodes_ancestor'
          a_submap = header_name.downcase
        end
        fields[index] = {
          format_id: fmt.id,
          position: index,
          validation: nil, # TODO...
          mapping: Field.mappings[mapping_name],
          special_handling: nil, # TODO...
          submapping: a_submap,
          expected_header: header_name,
          unique_in_format: assumption ? assumption.is_unique : false,
          can_be_empty: assumption ? !assumption.is_required : true
        }
        if mapping_name == 'to_ignored'
          ignored_fields << { file: table_name, reps: reps, head: header_name, term: field['term'] }
        end
      end
      Field.import!(fields)
    end
    ignored_fields.each do |ignored|
      puts "!! IGNORED #{ignored[:file]} (#{ignored[:reps]}) header: #{ignored[:head]} term: #{ignored[:term]}"
    end
  end
end
