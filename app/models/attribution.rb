# AKA an "agent" ... this is a person or organization that receives credit for some content. I apologize for changing
# the name, but, as represented (with a role attached), these really are *attributions*, not "agents". Someday perhaps
# we'll abstract the two, but not now.
class Attribution < ActiveRecord::Base
  has_many :content_attributions, inverse_of: :attribution
end
