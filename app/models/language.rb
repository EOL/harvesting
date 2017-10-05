class Language < ActiveRecord::Base
  has_many :media, inverse_of: :language

  def name
    code
  end
end
