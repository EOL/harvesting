class Reference < ActiveRecord::Base
  # has_many :article_references, inverse_of: :reference
  has_many :media_references, inverse_of: :reference
  has_many :media, through: :media_references
end
