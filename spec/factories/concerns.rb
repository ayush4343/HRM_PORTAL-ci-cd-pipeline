FactoryBot.define do
  factory :concern do
    name { Faker::Name.unique.name  }
    association :department, factory: :department
  end
end
