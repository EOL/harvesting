class Partner < ApplicationRecord
  establish_connection Rails.env.to_sym
  has_many :resources, inverse_of: :partner
end
