class CreateMessageNotifications < ActiveRecord::Migration
  def change
    create_table :message_notifications do |t|
      t.string :recipient
      t.integer :status_code_id
      t.string :type
      t.string :message_id
      t.string :message_group_id
      t.integer :merchant_store_id

      t.timestamps
    end
    add_index :message_notifications, :merchant_store_id
    add_index :message_notifications, :message_id, unique: true
  end
end
