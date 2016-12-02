class Resource < ActiveRecord::Base
  has_many :formats, inverse_of: :resource
end
