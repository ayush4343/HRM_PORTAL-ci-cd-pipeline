class AddOwnerNameToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :owner_name, :string
    add_column :organizations, :address, :string
  end
end
