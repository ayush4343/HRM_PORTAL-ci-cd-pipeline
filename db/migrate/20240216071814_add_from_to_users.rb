class AddFromToUsers < ActiveRecord::Migration[7.1]
  def change
      add_column :users, :shift_start, :datetime
      add_column :users, :shift_end, :datetime
      add_column :users, :buffer_time, :datetime
      add_column :users, :shift_mode, :integer  
  end
end
 