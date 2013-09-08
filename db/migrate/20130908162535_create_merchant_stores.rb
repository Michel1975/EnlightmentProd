class CreateMerchantStores < ActiveRecord::Migration
  def change
    create_table :merchant_stores do |t|
      t.boolean :active
      t.string :store_name
      t.text :description
      t.string :owner
      t.string :street
      t.string :house_number
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :latitude
      t.string :longitude
      t.string :sms_keyword

      t.timestamps
    end
    add_index :merchant_stores, :sms_keyword, unique: true
  end
end
