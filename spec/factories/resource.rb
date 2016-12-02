FactoryGirl.define do
  factory :resource do
    sequence(:site_id)
    sequence(:site_pk)
    sequence(:position)
    sequence(:name) { |n| "Resource ##{n}" }
    sequence(:abbr) { |n| "Res##{n}" }
  end
end
