class CreateGeolocations < ActiveRecord::Migration[7.2]
  def change
    create_table :geolocations do |t|
      t.string :ip_address, index: { unique: true }
      t.string :city, null: false
      t.string :country_name, null: false
      t.string :zip, null: false

      t.timestamps
    end
  end
end
