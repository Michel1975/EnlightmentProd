class AddCounterCacheToStore < ActiveRecord::Migration
  def change
    add_column :merchant_stores, :subscribers_count, :integer
    add_column :merchant_stores, :message_notifications_count, :integer
  end
end
