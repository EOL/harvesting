# This is really just the the join table, but we have resource_fks that need handling.
class MediaReference < ApplicationRecord
  belongs_to :medium, inverse_of: :media_references
  belongs_to :reference, inverse_of: :media_references
end
