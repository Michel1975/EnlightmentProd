class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.integer :member_id
      t.integer :merchant_store_id
      t.date :start_date

      t.timestamps
    end
    add_index :subscribers, :merchant_store_id
    add_index :subscribers, :member_id
    add_index :subscribers, [:merchant_store_id, :member_id], unique: true
  end
end
