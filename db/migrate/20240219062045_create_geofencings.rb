class CreateGeofencings < ActiveRecord::Migration[7.1]
  def change
    create_table :geofencings do |t|
      t.string :latitude
      t.string :longitude
      t.integer :radius
      t.references :organization

      t.timestamps
    end
  end
end
