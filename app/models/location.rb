class Location < ActiveRecord::Base
  has_many :media, inverse_of: :location
end
