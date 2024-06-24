class ContentAttribution < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :attribution, inverse_of: :content_attributions
  belongs_to :content, polymorphic: true
end
