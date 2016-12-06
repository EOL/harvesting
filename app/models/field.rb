class Field < ActiveRecord::Base
  belongs_to :format, inverse_of: :fields

  acts_as_list scope: :format

  enum validation: [:integer, :number, :uri]
end
