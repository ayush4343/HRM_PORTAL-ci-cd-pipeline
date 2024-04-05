class CreateLeaveRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :leave_requests do |t|
      t.date :start_date
      t.date :end_date
      t.integer :leave_type
      t.integer :user_ids, default: [], array: true
      t.string :reason
      t.string :start_time
      t.string :end_time
      t.boolean :paid_leave
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
