class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.integer :merchant_store_id
      t.integer :subscription_type_id
      t.date :start_date
      t.date :cancel_date
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :subscription_plans, :merchant_store_id
    add_index :subscription_plans, :subscription_type_id
  end
end
