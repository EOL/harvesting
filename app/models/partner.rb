class Partner < ActiveRecord::Base
  has_many :resources, inverse_of: :partner
end
