class MerchantUser < ActiveRecord::Base
  attr_accessible :name, :role, :merchant_user_attributes

  has_one :user, :as => :sub
  accepts_nested_attributes_for :user

  belongs_to :merchant_store

  validates :name, :role, :merchant_store_id, presence: true
  validates :admin, :inclusion => { :in => [true, false] }
end
