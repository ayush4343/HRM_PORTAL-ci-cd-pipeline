class AddNotificationTypeToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :notification_type, :string
    add_column :notifications, :parent_id, :integer
  end
end
