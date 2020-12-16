# See Flattener class.
class MetaXmlField < ApplicationRecord
  class << self
    def load
      # delete_all
      filename = Rails.root.join('db', 'data', 'meta_analyzed.json')
      raise("File missing: #{filename}") unless File.exist?(filename)
      
      data = JSON.parse(File.read(filename))
      have = {}
      all.each do |mxf|
        have["#{mxf.for_format}:#{mxf.term}"] = true
      end
      data.delete_if { |d| have.key?("#{d['for_format']}:#{d['term']}") }
      return nil if data.empty?

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
