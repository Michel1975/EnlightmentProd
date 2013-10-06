class AddFileToMerchantStore < ActiveRecord::Migration
  def change
    add_column :merchant_stores, :store_picture, :string
    add_column :merchant_stores, :store_picture_size, :integer
  end
end
