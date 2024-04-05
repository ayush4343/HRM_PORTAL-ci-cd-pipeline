class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :subject
      t.string :message
      t.boolean :is_read, default: false
      t.references :recipient
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
