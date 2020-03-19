class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  # Turning off this "protection" because harvesting ALMOST ALWAYS has fields that *look* required, but are infact allowed
  # as nulls because we have to populate the fields in a second pass (using a resource_pk to look up the ID in the DB).
  # It's just too much of a hassle to account for this is every case where it's needed.
  self.belongs_to_required_by_default = false
end
