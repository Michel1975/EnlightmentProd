class AddEmailToMerchantStore < ActiveRecord::Migration
  def change
    add_column :merchant_stores, :email, :string
  end
end
