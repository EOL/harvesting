class SectionParent < ApplicationRecord
  establish_connection Rails.env.to_sym
  belongs_to :section
  belongs_to :parent, class_name: 'Section'
end
