require 'faker'

FactoryBot.define do
  factory :request do
    title {"test_title"}
    description { "test_description" }
    status { "in_progress" }
    user_id {1}
  end
end