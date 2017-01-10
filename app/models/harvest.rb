class Harvest < ActiveRecord::Base
  belongs_to :resource, inverse_of: :harvests
  has_many :formats, inverse_of: :harvest, dependent: :destroy
  has_many :hlogs, inverse_of: :harvest, dependent: :destroy

  scope :completed, -> { where("completed_at IS NOT NULL") }
end
