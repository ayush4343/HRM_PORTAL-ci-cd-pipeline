class AddAddressToAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances , :address, :string
  end
end
