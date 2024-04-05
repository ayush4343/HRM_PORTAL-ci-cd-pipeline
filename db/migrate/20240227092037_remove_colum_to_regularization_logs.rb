class RemoveColumToRegularizationLogs < ActiveRecord::Migration[7.1]
  def change
    remove_column :regularization_logs, :punch_in_times
    remove_column :regularization_logs, :punch_out_times
  end
end
