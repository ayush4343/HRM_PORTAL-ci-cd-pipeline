FactoryBot.define do
  factory :role do
    name { Faker::Name.unique.name }
    association :organization, factory: :organization
  end
end
