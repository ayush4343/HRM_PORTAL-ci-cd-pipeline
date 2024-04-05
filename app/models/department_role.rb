class DepartmentRole < ApplicationRecord
  belongs_to :role
  belongs_to :department
end
