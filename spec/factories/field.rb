FactoryBot.define do
  factory :field do
    association(:format)
    sequence(:position)
    expected_header { "you should really specify this" }
    mapping { :resource_pk }
  end
end
