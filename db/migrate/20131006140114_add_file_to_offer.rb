class AddFileToOffer < ActiveRecord::Migration
  def change
    add_column :offers, :offer_picture, :string
    add_column :offers, :offer_picture_size, :integer
  end
end
