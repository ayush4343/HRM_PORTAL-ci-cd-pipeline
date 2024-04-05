class AddPunchInTimesToRegularizationLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :regularization_logs , :punch_in_times, :datetime, array: true, default: []
    add_column :regularization_logs , :punch_out_times, :datetime, array: true, default: []
  end
end
