class Dataset <ApplicationRecord
  self.primary_key = 'id' # Yes, this looks weird, but because it's a string, we had to do this.
  has_many :scientific_names, inverse_of: :dataset
end
