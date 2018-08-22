class Reference < ActiveRecord::Base
  belongs_to :resource, inverse_of: :references
  has_many :nodes_references, inverse_of: :reference
  # has_many :article_references, inverse_of: :reference
  has_many :traits_references, inverse_of: :reference
  has_many :assocs_references, inverse_of: :reference
  has_many :media_references, inverse_of: :reference
  has_many :articles_references, inverse_of: :reference
  has_many :media, through: :media_references
  has_many :articles, through: :articles_references
  has_many :nodes, through: :nodes_references

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
