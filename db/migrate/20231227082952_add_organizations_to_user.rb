class AddOrganizationsToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :organization, index: true
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :gender, :integer
  end
end
