class Location < ActiveRecord::Base
  has_many :media, inverse_of: :location
  has_many :articles, inverse_of: :location
end
