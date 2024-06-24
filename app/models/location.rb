class Location < ApplicationRecord
  establish_connection Rails.env.to_sym
  has_many :media, inverse_of: :location
  has_many :articles, inverse_of: :location
end
