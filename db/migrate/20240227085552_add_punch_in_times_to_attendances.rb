class AddPunchInTimesToAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances , :punch_in_times, :datetime, array: true, default: []
    add_column :attendances , :punch_out_times, :datetime, array: true, default: []
  end
end
