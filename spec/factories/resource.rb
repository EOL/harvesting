FactoryBot.define do
  factory :resource do
    sequence(:position)
    sequence(:name) { |n| "Resource ##{n}" }
    sequence(:abbr) { |n| "Res##{n}" }
  end
end
