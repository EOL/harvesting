class Harvest < ActiveRecord::Base
  has_many :formats, inverse_of: :harvest
end
