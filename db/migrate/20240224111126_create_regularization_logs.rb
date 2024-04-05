class CreateRegularizationLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :regularization_logs do |t|
      t.references :regularization, null: false, foreign_key: true
      t.time :punch_in_times
      t.time :punch_out_times
      t.date :date

      t.timestamps
    end
  end
end
