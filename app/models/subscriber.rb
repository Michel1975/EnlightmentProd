class Subscriber < ActiveRecord::Base
  attr_accessible :member_id, :start_date

  has_many :campaign_members #no dependent destroy due to historic campaign tracking for merchant
  belongs_to :merchant_store

  validates :merchant_store_id, :member_id, :start_date,  presence: true
  validates :active, :inclusion => { :in => [ true, false ] }
end
