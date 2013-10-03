class AddFieldToMerchantStore < ActiveRecord::Migration
  def change
    add_column :merchant_stores, :short_description, :text
  end
end
