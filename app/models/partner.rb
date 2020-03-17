class Partner < ApplicationRecord
  has_many :resources, inverse_of: :partner
end
