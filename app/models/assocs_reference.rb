# This is really just the the join table, but we have resource_fks that need handling.
class AssocsReference < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :assoc, inverse_of: :assocs_references
  belongs_to :harvest, inverse_of: :assocs_references
  belongs_to :reference, inverse_of: :assocs_references
end
