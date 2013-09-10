class MerchantUser < ActiveRecord::Base
  attr_accessible :admin, :name, :role

  has_one :user, as: => :sub
  belongs_to :merchant_store
end
