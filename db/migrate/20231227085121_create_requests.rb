class CreateRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :requests do |t|
      t.string :title
      t.text :description
      t.integer :status, default: 0,null: false
      t.timestamps
    end
  end
end
