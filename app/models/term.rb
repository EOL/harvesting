class Term < ActiveRecord::Base
  enum used_for: %i[unknown measurement association value metadata]
end
