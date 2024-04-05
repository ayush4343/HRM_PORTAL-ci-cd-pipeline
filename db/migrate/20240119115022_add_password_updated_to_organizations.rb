class AddPasswordUpdatedToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :password_updated, :boolean, default: false
    add_column :organizations, :email_verified_for_reset_password, :boolean, null: false, default: false
  end
end
