# This is really just the the join table, but we have resource_fks that need handling.
class NodesReference < ApplicationRecord
  belongs_to :node, inverse_of: :nodes_references
  belongs_to :reference, inverse_of: :nodes_references
end
