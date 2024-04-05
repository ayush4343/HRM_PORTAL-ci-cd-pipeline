class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :email
      t.string :company_name
      t.string :website
      t.string :contact
      t.timestamps
    end
  end
end
