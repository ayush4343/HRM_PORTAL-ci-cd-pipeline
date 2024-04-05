FactoryBot.define do
  factory :attendance do
    punch_in { "2024-02-18 18:48:59" }
    punch_out { "2024-02-18 18:48:59" }
    status { "MyString" }
    user { nil }
  end
end
