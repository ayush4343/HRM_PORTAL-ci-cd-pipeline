class AddDeviceTokenToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations , :device_type, :integer
    add_column :organizations, :device_token, :string
  end
end
