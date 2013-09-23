class ChangeActiveColumnInMerchantStore < ActiveRecord::Migration
  def change
 	change_column :merchant_stores, :active, :boolean, default: false
  end
end
