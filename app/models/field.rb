class Field < ActiveRecord::Base
  belongs_to :format, inverse_of: :fields

  acts_as_list scope: :format

  enum validation: [ :must_be_integers, :must_be_numerical, :must_know_uris ]

end
