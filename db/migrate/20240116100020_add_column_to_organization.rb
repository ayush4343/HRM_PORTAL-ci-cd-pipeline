class AddColumnToOrganization < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :password_digest, :string
    add_column :organizations, :activated, :boolean, default: false
  end
end
