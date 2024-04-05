class RemoveColumToAttendances < ActiveRecord::Migration[7.1]
  def change
    remove_column :attendances, :punch_in_times
    remove_column :attendances, :punch_out_times
  end
end
