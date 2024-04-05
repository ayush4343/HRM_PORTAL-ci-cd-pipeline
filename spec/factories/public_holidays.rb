require 'faker'

FactoryBot.define do
  factory :public_holiday do
    name { Faker::Name.unique.name }
    start_date { Faker::Date.between(from: Date.today, to: 1.year.from_now) }
    end_date { Faker::Date.between(from: start_date, to: start_date + 7.days) }
  end
end

