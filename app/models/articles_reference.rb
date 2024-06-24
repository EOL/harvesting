# This is really just the the join table, but we have resource_fks that need handling.
class ArticlesReference < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :article, inverse_of: :articles_references, optional: true
  belongs_to :reference, inverse_of: :articles_references, optional: true
end
