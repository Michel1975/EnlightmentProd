class AddPhoneToMerchantShore < ActiveRecord::Migration
  def change
    add_column :merchant_stores, :phone, :string
  end
end
