class RemoveImageAttributesFromOffer < ActiveRecord::Migration
  def change
  	remove_column :offers, :offer_picture
  	remove_column :offers, :offer_picture_size
  end
end
