# This is really just the the join table, but we have resource_fks that need handling.
class AssocsReference < ActiveRecord::Base
  belongs_to :assoc, inverse_of: :assocs_references
  belongs_to :reference, inverse_of: :assocs_references
end
