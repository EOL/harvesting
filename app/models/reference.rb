class Reference < ActiveRecord::Base
  has_many :media
  has_and_belongs_to_many :articles
end
