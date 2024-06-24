# See Flattener class.
class MetaXmlField < ApplicationRecord
  establish_connection Rails.env.to_sym
  class << self
    def load
      filename = Rails.root.join('db', 'data', 'meta_analyzed.json')
      raise("File missing: #{filename}") unless File.exist?(filename)

      data = JSON.parse(File.read(filename))
      puts "I see #{data.size} items."

      have = {}
      all.each do |mxf|
        have["#{mxf.for_format}:#{mxf.term}"] = mxf
      end

      to_import = []
      to_update = {}

      data.each do |datum|
        key = "#{datum['for_format']}:#{datum['term']}"

        if !have.include?(key)
          to_import << datum
        else
          existing = have[key]
          clean_datum = datum.compact
          clean_attrs = existing.attributes.compact
          clean_attrs.delete('id')

          to_update[existing.id] = datum unless clean_datum == clean_attrs
        end
      end

      puts "I have #{to_import.length} new mappings to import and #{to_update.length} records to update"

      if to_import.any?
        puts "** ADDING #{to_import.length} new meta xml fields"
        import!(to_import, on_duplicate: :ignore)
      end

      if to_update.any?
        puts "** UPDATING #{to_update.length} existing meta xml fields"
        update(to_update.keys, to_update.values)
      end
    end

    # json = %{{"term":"http://iptc.org/std/Iptc4xmpExt/1.0/xmlns/LocationCreated",
    # "for_format":"media",
    # "represents":"to_media_description",
    # "submapping":null,
    # "is_unique":false,
    # "is_required":false}}
    # MetaXmlField.add_from_json(json)
    def add_from_json(json)
      data = JSON.parse(json)
      import!([data], on_duplicate: :ignore)
    end
  end
end
