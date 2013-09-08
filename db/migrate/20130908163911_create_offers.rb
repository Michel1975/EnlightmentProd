class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :title
      t.text :description
      t.date :valid_from
      t.date :valid_to
      t.integer :merchant_store_id

      t.timestamps
    end
    add_index :offers, :merchant_store_id
  end
end
