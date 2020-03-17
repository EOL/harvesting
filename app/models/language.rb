class Language < ApplicationRecord
  has_many :media, inverse_of: :language
  has_many :articles, inverse_of: :language

  def name
    code
  end
end
