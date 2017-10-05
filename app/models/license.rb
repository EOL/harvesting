class License < ActiveRecord::Base
  has_many :media, inverse_of: :license
end
