class AddFieldsToRequest < ActiveRecord::Migration[7.1]
  def change
    add_column :requests, :type_of_concern, :integer
    add_reference :requests, :department, null: false, foreign_key: true
    add_column :requests, :concern_related, :integer
  end
end
