class CreateDepartmentRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :department_roles do |t|
      t.references :role, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end
  end
end
