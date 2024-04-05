class AddReferencesToorganizations < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_otps, :organization, foreign_key: true
  end
end
