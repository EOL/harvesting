# NOTE: this is horrible name, and I am only really keeping it to conform to Rails' conventions. Really, it's "Content
# Attribution," a join between a content item and an attribution. One content can have many attributions, and one
# attribution can be assigned to many contents (from the same resource).
class AttributionsContent
  belongs_to :attribution, inverse_of: :attributions_contents
  belongs_to :content, polymorphic: true
end
