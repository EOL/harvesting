# This is really just the the join table, but we have resource_fks that need handling.
class MediaReference < ActiveRecord::Base
  belongs_to :medium
  belongs_to :reference
end
