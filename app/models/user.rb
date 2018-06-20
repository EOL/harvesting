class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :lockable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable
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
