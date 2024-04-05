class Department < ApplicationRecord
  # Assoiciations
  has_many :department_roles, dependent: :destroy
  has_many :roles, through: :department_roles 
  has_many :concerns, dependent: :destroy
  has_many :requests, dependent: :destroy
  belongs_to :organization
  has_many :requests, dependent: :destroy
end
