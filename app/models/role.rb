class Role < ApplicationRecord

  # assocaition
  has_many :role_permissions
  has_many :permissions, through: :role_permissions, dependent: :destroy
  has_many :users, dependent: :destroy
  belongs_to :organization

  # validation
  validates :name, presence: true, uniqueness: { scope: :organization_id }, if: -> { organization_id.present? }
end
