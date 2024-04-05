class AddTotalTimeToAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances, :total_time, :string
  end
end
