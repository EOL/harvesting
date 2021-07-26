class PublishDiff < ApplicationRecord
  belongs_to :resource
  validates_presence_of :resource_id, :t1, :t2, :status
end
