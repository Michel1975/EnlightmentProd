class RemoveImageAttributesFromStore < ActiveRecord::Migration
  def change
  	remove_column :merchant_stores, :store_picture
  	remove_column :merchant_stores, :store_picture_size
  end
end
