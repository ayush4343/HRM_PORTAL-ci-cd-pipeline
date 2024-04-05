class AddPasswordUpdatedToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_updated, :boolean, default: false
  end
end
