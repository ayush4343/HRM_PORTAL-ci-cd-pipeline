class CreateRegularizations < ActiveRecord::Migration[7.1]
  def change
    create_table :regularizations do |t|
      t.time :reg_punch_in_times,  array: true, default: []
      t.time :reg_punch_out_times, array: true, default: [] 
      t.integer :user_ids, array: true, default: []
      t.integer :status
      t.text    :reason
      t.references :attendance
      t.references :user
      t.date :date

      t.timestamps
    end
  end
end
