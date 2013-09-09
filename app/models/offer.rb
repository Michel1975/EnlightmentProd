class Offer < ActiveRecord::Base
  attr_accessible :description, :merchant_store_id, :title, :valid_from, :valid_to

  belongs_to :merchant_store
end
