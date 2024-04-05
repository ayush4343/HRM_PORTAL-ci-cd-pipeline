class CreateUserOtps < ActiveRecord::Migration[7.1]
  def change
    create_table :user_otps do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :verification_code

      t.timestamps
    end
  end
end
