class CreateWelcomeOffers < ActiveRecord::Migration
  def change
    create_table :welcome_offers do |t|
      t.boolean :active
      t.text :description
      t.integer :merchant_store_id

      t.timestamps
    end
    add_index :welcome_offers, :merchant_store_id
  end
end
