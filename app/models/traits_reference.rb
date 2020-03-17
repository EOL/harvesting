# This is really just the the join table, but we have resource_fks that need handling.
class TraitsReference < ActiveRecord::Base
  belongs_to :trait, inverse_of: :traits_references
  belongs_to :reference, inverse_of: :traits_references
end
