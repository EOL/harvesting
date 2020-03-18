# Make `form_with` generate id attributes for any generated HTML tags.
# Rails.application.config.action_view.form_with_generates_ids = true

# Turning off this "protection" because harvesting ALMOST ALWAYS has fields that *look* required, but are infact allowed
# as nulls because we have to populate the fields in a second pass (using a resource_pk to look up the ID in the DB).
# It's just too much of a hassle to account for this is every case where it's needed.
Rails.application.config.active_record.belongs_to_required_by_default = false
