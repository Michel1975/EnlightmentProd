class CreateEventHistories < ActiveRecord::Migration
  def change
    create_table :event_histories do |t|
      t.text :description
      t.string :type
      t.integer :merchant_store_id

      t.timestamps
    end
    add_index :event_histories, :merchant_store_id
  end
end
