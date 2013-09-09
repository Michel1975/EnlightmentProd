class AddForeignKeyToMerchantUsers < ActiveRecord::Migration
  def change
    add_column :merchant_users, :merchant_store_id, :integer
  end
end
