require 'faker'

FactoryBot.define do
  factory :notification do
    subject {"test_subject"}
    is_read { true }
    recipient_id {1}
    message {"Test"}
  end
end