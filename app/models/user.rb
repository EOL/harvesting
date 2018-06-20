class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :lockable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable
  has_secure_password
  validates :email, presence: true
end
