FactoryBot.define do
  factory :term do
    sequence(:uri) { |n| "http://domain.com/path/term_#{n}" }
    sequence(:name) { |n| "Term #{n}" }
    definition { "You probably should have added a definition here." }
  end
end
