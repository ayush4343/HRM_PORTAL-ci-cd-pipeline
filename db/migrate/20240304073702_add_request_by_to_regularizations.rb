class AddRequestByToRegularizations < ActiveRecord::Migration[7.1]
  def change
    add_column :regularizations, :requested_by, :string
    add_column :regularizations, :action_by, :string
  end
end
