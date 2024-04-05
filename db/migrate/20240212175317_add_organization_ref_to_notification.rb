class AddOrganizationRefToNotification < ActiveRecord::Migration[7.1]
  def change
    add_reference :notifications, :organization, foreign_key: true
  end
end
