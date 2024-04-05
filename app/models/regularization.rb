class Regularization < ApplicationRecord
  belongs_to :attendance
  belongs_to :user
  validates :reason, presence: true
  enum status: [:pending, :approved, :rejected, :cancel]
  # has_many :regularization_logs, dependent: :destroy
  # accepts_nested_attributes_for :regularization_logs, :allow_destroy => true
  serialize :punch_in_times, JSON
  serialize :punch_out_times, JSON
end
