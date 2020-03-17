# This is really just the the join table, but we have resource_fks that need handling.
class ScientificNamesReference < ApplicationRecord
  belongs_to :scientific_name, inverse_of: :scientific_names_references
  belongs_to :reference, inverse_of: :scientific_names_references
end
