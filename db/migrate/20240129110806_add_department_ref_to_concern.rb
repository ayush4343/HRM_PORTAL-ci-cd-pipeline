class AddDepartmentRefToConcern < ActiveRecord::Migration[7.1]
  def change
    add_reference :concerns, :department, foreign_key: true
  end
end
