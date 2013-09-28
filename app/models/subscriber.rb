class Subscriber < ActiveRecord::Base
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  
  attr_accessible :member_id, :start_date

  has_many :campaign_members #no dependent destroy due to historic campaign tracking for merchant
  belongs_to :merchant_store
  belongs_to :member

  validates :merchant_store_id, :member_id, :start_date,  presence: true
  validates :active, :inclusion => { :in => [ true, false ] }
end
