class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :title
      t.text :message
      t.string :status
      t.datetime :activation_time
      t.boolean :instant_activation, default: false
      t.string :message_group_id
      t.integer :merchant_store_id

      t.timestamps
    end
    add_index :campaigns, :merchant_store_id
    add_index :campaigns, :message_group_id, unique: true
  end
end
