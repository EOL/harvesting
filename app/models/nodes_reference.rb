# This is really just the the join table, but we have resource_fks that need handling.
class NodesReference < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :node, inverse_of: :nodes_references
  belongs_to :reference, inverse_of: :nodes_references
end
