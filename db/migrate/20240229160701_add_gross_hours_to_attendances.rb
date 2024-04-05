class AddGrossHoursToAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances, :gross_hours, :string
  end
end
