# See Flattener class.
class MetaXmlField < ActiveRecord::Base
  def self.read_analyzed
    filename = Rails.root.join('db', 'data', 'meta_analyzed.json')
    if File.exist?(filename)
      data = JSON.parse(File.read(filename))
      import!(data, on_duplicate: :ignore)
    end
  end
end
