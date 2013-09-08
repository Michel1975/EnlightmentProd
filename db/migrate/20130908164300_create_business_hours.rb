class CreateBusinessHours < ActiveRecord::Migration
  def change
    create_table :business_hours do |t|
      t.integer :day
      t.time :open_time
      t.time :close_time
      t.integer :merchant_store_id

      t.timestamps
    end
    add_index :business_hours, :merchant_store_id
  end
end
