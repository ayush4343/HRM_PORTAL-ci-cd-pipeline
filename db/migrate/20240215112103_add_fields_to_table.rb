class AddFieldsToTable < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :type, :string
    add_column :users, :type, :string
  end
end
