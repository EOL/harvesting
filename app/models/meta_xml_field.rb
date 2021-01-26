# See Flattener class.
class MetaXmlField < ApplicationRecord
  class << self
    def load
      filename = Rails.root.join('db', 'data', 'meta_analyzed.json')
      raise("File missing: #{filename}") unless File.exist?(filename)

      data = JSON.parse(File.read(filename))
      puts "I see #{data.size} items."

      # remove things from the list if we already know about them:
      have = {}
      all.each do |mxf|
        have["#{mxf.for_format}:#{mxf.term}"] = true
      end
      data.delete_if { |d| have.key?("#{d['for_format']}:#{d['term']}") }

      puts "After removing known fields, I now have #{data.size} items."
      if data.empty?
        puts "** NOTHING NEW TO ADD. No action taken."
        return nil
      end

      puts "** ADDING #{data.size} new meta xml fields"
      import!(data, on_duplicate: :ignore)
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
