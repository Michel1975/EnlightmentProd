class Subscriber < ActiveRecord::Base
  attr_accessible :member_id, :merchant_store_id, :start_date, :active

  has_many :campaign_members #no dependent destroy due to historic campaign tracking for merchant
  belongs_to :merchant_store
end
