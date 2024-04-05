class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :user,  foreign_key: true
      t.references :organization,  foreign_key: true
      t.references :request, foreign_key: true

      t.timestamps
    end
  end
end
