FactoryBot.define do
  factory :permission do
    name { Faker::Name.unique.name }
  end
end
