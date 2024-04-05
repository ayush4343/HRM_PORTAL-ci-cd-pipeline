class RemoveUserFromUsers < ActiveRecord::Migration[7.1]
  def up
    remove_column :users, :role
  end

  def down
    add_column :users, :role, :integer
  end
end
