class Article < ApplicationRecord
  belongs_to :resource, inverse_of: :articles
  belongs_to :harvest, inverse_of: :articles
  belongs_to :node, inverse_of: :articles
  belongs_to :license
  belongs_to :language
  belongs_to :location, inverse_of: :articles
  belongs_to :bibliographic_citation

  has_many :articles_references, inverse_of: :article
  has_many :references, through: :articles_references

  has_many :content_attributions, as: :content
  has_many :attributions, through: :content_attributions

  has_many :articles_sections
  has_many :sections, through: :articles_sections

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
