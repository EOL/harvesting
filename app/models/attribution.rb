# AKA an "agent" ... this is a person or organization that receives credit for some content. TODO: I errantly created an
# agents table that virtually duplicates this one. I'm going to keep it (because we may decide it's needed), but we
# should re-think how these are all handled.
class Attribution < ActiveRecord::Base
  belongs_to :role, inverse_of: :attributions
  has_many :attributions_contents, inverse_of: :attribution
end
