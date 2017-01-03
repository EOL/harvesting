class Vernacular < ActiveRecord::Base
  belongs_to :resource, inverse_of: :vernaculars
  belongs_to :node, inverse_of: :vernaculars
  belongs_to :language
end
