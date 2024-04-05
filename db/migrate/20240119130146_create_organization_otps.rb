class CreateOrganizationOtps < ActiveRecord::Migration[7.1]
  def change
    create_table :organization_otps do |t|
      t.references :organization, null: false, foreign_key: true
      t.integer :verification_code

      t.timestamps
    end
  end
end
