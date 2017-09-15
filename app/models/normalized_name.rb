# This is a simple "copy" of a scientific name that allows us to match many complex scientific names to simpler "unique"
# names.
class NormalizedName < ActiveRecord::Base
  # These are all of the sci. names that we consider "the same," regardless of their quirky individualisms:
  has_many :scientific_names
end
