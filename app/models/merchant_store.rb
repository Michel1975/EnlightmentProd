class MerchantStore < ActiveRecord::Base
  attr_accessible :store_name, :description, :owner, :street, :house_number, :postal_code, :city, :country, :latitude, :longitude, :sms_keyword, :business_hours_attributes
  
  has_one :welcome_offer, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :business_hours, dependent: :destroy
  has_many :message_notifications, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_one  :subscription_plan, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :event_histories, dependent: :destroy
  has_many :merchant_users, dependent: :destroy
  has_many :subscribers, dependent: :destroy
  has_many :members, :through => :subscribers
  accepts_nested_attributes_for :business_hours
  
  validates :active, :inclusion => { :in => [ true, false ] }
  validates :store_name, presence: true, length: { maximum: 30 }
  validates :description, :city, :country, presence: true
  validates :owner, presence: true, length: { maximum: 30 }
  validates :street, presence: true, length: { maximum: 30 }
  validates :house_number, :postal_code, numericality: { only_integer: true }, length: { maximum: 4 } 
  validates :sms_keyword, presence: true, uniqueness: { case_sensitive: false }


  geocoded_by :address
  after_validation :geocode
  
  def address
    return street + " " + house_number + " " + postal_code + " " + city + " Denmark"
  end
  
end
