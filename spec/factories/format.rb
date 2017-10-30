FactoryBot.define do
  factory :format do
    association(:resource)
    get_from { "YOU SHOULD REALLY SPECIFY THIS" }
    represents { :images }
  end
end
