class MerchantStore < ActiveRecord::Base
  attr_accessible :active, :city, :country, :description, :house_number, :latitude, :longitude, :owner, :postal_code, :sms_keyword, :store_name, :street

  has_one :welcome_offer, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :business_hours, dependent: :destroy
  has_many :message_notifications, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_many :subscription_plans, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :event_histories, dependent: :destroy
  has_many :merchant_users, dependent: :destroy

  
end
