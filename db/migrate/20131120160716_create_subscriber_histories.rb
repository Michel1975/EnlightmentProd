class CreateSubscriberHistories < ActiveRecord::Migration
  def change
    create_table :subscriber_histories do |t|
      t.string :event_type
      t.integer :member_id
      t.integer :merchant_store_id

      t.timestamps
    end
  end
end
