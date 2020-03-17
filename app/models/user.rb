class User < ActiveRecord::Base
  # Removed :registerable because we don't want people signing up without "permission".
  devise :confirmable, :database_authenticatable, :lockable, :recoverable, :rememberable, :trackable, :validatable
  validates :email, presence: true

  # NOTE: this is a hook called by Devise
  def after_confirmation
    activate
  end

  def activate
    skip_confirmation!
    save
  end

  def grant_admin
    self.update_attribute(:is_admin, true)
  end

  def revoke_admin
    self.update_attribute(:is_admin, false)
  end
end
