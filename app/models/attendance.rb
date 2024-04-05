class Attendance < ApplicationRecord
  # Assoiciations
  has_many :regularizations, dependent: :destroy
  belongs_to :user

  # enum
  enum status: [:on_time, :late]
  
end
