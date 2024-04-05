require 'faker'

FactoryBot.define do
  factory :organization do
    company_name {Faker::Company.name}
    password {Faker::Internet.password}
    email { Faker::Internet.email }
    website { Faker::Internet.url }
    contact {  Faker::PhoneNumber.phone_number}
    owner_name {Faker::Name.name}
    address {Faker::Address.full_address}
  end
end