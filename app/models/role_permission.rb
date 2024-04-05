class RolePermission < ApplicationRecord
  # Assoiciations
  belongs_to :role
  belongs_to :permission
end
