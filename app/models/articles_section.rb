class ArticlesSection < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :article, inverse_of: :articles_sections
  belongs_to :section, inverse_of: :articles_sections
end
