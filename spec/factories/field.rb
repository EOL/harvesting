FactoryBot.define do
  factory :field do
    association(:format)
    sequence(:position)
    expected_header { "you should really specify this" }
    map_to_table { :nodes }
    map_to_field { :resource_pk }
  end
end
