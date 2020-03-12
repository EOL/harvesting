# This is really just the the join table, but we have resource_fks that need handling.
class ArticlesReference < ApplicationRecord
  belongs_to :article, inverse_of: :articles_references
  belongs_to :reference, inverse_of: :articles_references
end
