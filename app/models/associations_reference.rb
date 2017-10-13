# This is really just the the join table, but we have resource_fks that need handling.
class AssociationsReference < ActiveRecord::Base
  belongs_to :association, inverse_of: :associations_references
  belongs_to :reference, inverse_of: :associations_references
end
