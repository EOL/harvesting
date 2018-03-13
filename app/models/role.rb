class Role < ActiveRecord::Base
  has_many :attributions, inverse_of: :role

  acts_as_list
end
