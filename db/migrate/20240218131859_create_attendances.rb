class CreateAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :attendances do |t|
      t.time :punch_in_times,  array: true, default: []
      t.time :punch_out_times, array: true, default: [] 
      t.date :date
      t.integer :status
      t.integer :punch_type
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
