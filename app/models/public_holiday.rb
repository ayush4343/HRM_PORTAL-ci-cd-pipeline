class PublicHoliday < ApplicationRecord
	validates :name, presence: true, uniqueness: true
	has_and_belongs_to_many :organizations, dependent: :destroy, join_table: :organizations_public_holidays
end