class AddOrganizationRefToDepartment < ActiveRecord::Migration[7.1]
  def change
    add_reference :departments, :organization, null: false, foreign_key: true
  end
end
