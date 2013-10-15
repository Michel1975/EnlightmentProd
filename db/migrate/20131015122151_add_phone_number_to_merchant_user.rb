class AddPhoneNumberToMerchantUser < ActiveRecord::Migration
  def change
    add_column :merchant_users, :phone, :string
  end
end
