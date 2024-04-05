class Permission < ApplicationRecord
  has_many :role_permissions 
  has_many :roles, through: :role_permissions, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
