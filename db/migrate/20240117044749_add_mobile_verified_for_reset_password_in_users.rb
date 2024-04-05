class AddMobileVerifiedForResetPasswordInUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :mobile_verified_for_reset_password, :boolean, null: false, default: false
  end
end
