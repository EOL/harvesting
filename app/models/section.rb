class Section < ActiveRecord::Base
  has_many :articles_sections
  has_many :articles, through: :articles_sections
  has_many :section_parents
  has_many :section_values

  acts_as_list
end
