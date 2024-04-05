class ChangeDataTypeForDeviceToken < ActiveRecord::Migration[7.1]
  def up
    change_column :users, :device_token, :string
  end

  def down
    change_column :users, :device_token, :integer
  end
end
