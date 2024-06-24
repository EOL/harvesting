# This is really just the the join table, but we have resource_fks that need handling.
class TraitsReference < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :trait, inverse_of: :traits_references
  belongs_to :reference, inverse_of: :traits_references
end
