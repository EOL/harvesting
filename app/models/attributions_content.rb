class ContentAttribution
  belongs_to :attribution, inverse_of: :attributions_contents
  belongs_to :content, polymorphic: true
end
