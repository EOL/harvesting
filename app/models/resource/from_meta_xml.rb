class Resource
  # Read a meta.xml config file and create the resource file formats.
  class FromMetaXml
    attr_accessor :resource, :path, :doc

    class << self
      def self.by_path(path)
        abbr = File.basename(loc)
        # NOTE: the type is :csv because we don't have XML defining an Excel spreadsheet.
        resource = if Resource.exists?(abbr: abbr.downcase)
          Resource.find(abbr: abbr.downcase)
        else
          Resource.create(name: abbr.titleize, abbr: abbr.downcase, pk_url: '$PK')
          resource.partner = resource.fake_partner
          resource.save
          resource
        end
        new(resource).import
      end

      # A method to re-generate the meta_xml_analyzed file. Basically this allows us to "learn" from past resources how
      # future fields should be mapped. TODO: this should be extracted to its own class. :\ MetaXmlToFieldMapper
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
          # TODO: Some of this logic beglongs in the MetaXml class.
          @doc = File.open(filename) { |f| Nokogiri::XML(f) }
          @doc.css('archive table').each do |file_config|
            location = file_config.css("location").first.text
            puts "++ #{resource.name}/#{location}"
            file_config.css('field').each do |field|
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
    end

    def initialize(resource)
      @resource = resource
    end

    def import
      process = LoggedProcess.new(@resource)
      process.run_step('Parse meta.xml file and create formats with fields') do
        @resource.formats&.abstract&.delete_all
        meta_xml = MetaXml.new(@resource)
        meta_xml.create_models
        meta_xml.warnings.each { |warning| process.warn(warning) }
      end
    end
  end
end
