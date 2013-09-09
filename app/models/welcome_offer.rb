class WelcomeOffer < ActiveRecord::Base
  attr_accessible :active, :description, :merchant_store_id

  belongs_to :merchant_store
end
