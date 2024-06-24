class SectionValue < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :section
end
