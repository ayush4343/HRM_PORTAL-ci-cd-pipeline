FactoryBot.define do
  factory :department do
    name { Faker::Name.unique.name }
    association :organization, factory: :organization
  end
end
