class Article < ActiveRecord::Base
  belongs_to :resource, inverse_of: :articles
  belongs_to :harvest, inverse_of: :articles
  belongs_to :node, inverse_of: :articles
  belongs_to :license
  belongs_to :language
  belongs_to :location, inverse_of: :articles
  belongs_to :bibliographic_citation

  has_many :articles_references, inverse_of: :article
  has_many :references, through: :articles_references

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
