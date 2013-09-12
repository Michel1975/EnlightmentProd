class MerchantUser < ActiveRecord::Base
  attr_accessible :name, :role

  has_one :user, :as => :sub
  belongs_to :merchant_store

  validates :name, :role, :merchant_store_id, presence: true
  validates :admin, :inclusion => { :in => [true, false] }
end
