class Identifier < ActiveRecord::Base
  belongs_to :resource, inverse_of: :identifiers
  belongs_to :harvest, inverse_of: :identifiers
  belongs_to :node, inverse_of: :identifiers
end
