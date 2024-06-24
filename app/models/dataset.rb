class Dataset < ApplicationRecord
  establish_connection Rails.env.to_sym
  self.primary_key = 'id' # Yes, this looks weird, but because it's a string, we had to do this.
  has_many :scientific_names, inverse_of: :dataset

  def self.import_csv
    file = Rails.root.join('db', 'data', 'datasets.csv')
    if File.exist?(file)
      puts '.. Importing datasets'
      datasets = []
      headers = nil
      CSV.foreach(file, encoding: 'UTF-8') do |row|
        if headers.nil?
          headers = row
        else
          data = {}
          row.each_with_index do |field, i|
            data[headers[i]] = field
          end
          datasets << data
        end
      end
      Dataset.import(datasets, on_duplicate_key_update: [:link, :publisher, :supplier, :metadata])
    else
      puts "NO datasets file found (#{file}), skipping. Your names attributions may be missing."
    end
  end

end
