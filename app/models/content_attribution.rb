class ContentAttribution < ApplicationRecord
  belongs_to :attribution, inverse_of: :content_attributions
  belongs_to :content, polymorphic: true
end
