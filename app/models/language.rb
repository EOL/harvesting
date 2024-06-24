class Language < ApplicationRecord
  establish_connection Rails.env.to_sym
  has_many :media, inverse_of: :language
  has_many :articles, inverse_of: :language

  def name
    code
  end
end
