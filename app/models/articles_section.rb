class ArticlesSection < ApplicationRecord
  belongs_to :article, inverse_of: :articles_sections
  belongs_to :section, inverse_of: :articles_sections
end
