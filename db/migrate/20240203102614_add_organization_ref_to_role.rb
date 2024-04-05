class AddOrganizationRefToRole < ActiveRecord::Migration[7.1]
  def change
    add_reference :roles, :organization, foreign_key: true
  end
end
