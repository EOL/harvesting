class Identifier < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :resource, inverse_of: :identifiers
  belongs_to :harvest, inverse_of: :identifiers
  belongs_to :node, inverse_of: :identifiers

  def as_json(*)
    super(only: :identifier)
  end
end
