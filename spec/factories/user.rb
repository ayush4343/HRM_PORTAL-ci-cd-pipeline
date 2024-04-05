FactoryBot.define do
  factory :user do
    name { "XYZ" }
    username {"Test"}
    email { Faker::Internet.email }
    password {Faker::Internet.password}
    first_name {"test_first_name"}
    middle_name {"test_last_name"}
    last_name {"test_last_name"}
    phone_number {"123456789"}
    gender {"male"}
    device_type {"android"}
    device_token {"test_devise_token"}
    shift_start {"10:00:00"}
    shift_end {"19:00:00"}
    buffer_time {"00:15:00"}
    shift_mode {"fixed"}
    association :organization, factory: :organization
  end
end

               