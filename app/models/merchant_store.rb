class MerchantStore < ActiveRecord::Base
  attr_accessible :store_name, :store_picture, :store_picture_size, :description, :short_description, :owner, :phone, :street, :house_number, :postal_code, :city, :country, :latitude, :longitude, :sms_keyword, :business_hours_attributes
  
  mount_uploader :store_picture, ImageUploader
  
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

  before_save { |store| store.sms_keyword = store.sms_keyword.downcase }#af hensyn til match-forespørgsler ved sms-tilmelding

  validates :active, :inclusion => { :in => [ true, false ] }
  validates :store_name, presence: true, length: { maximum: 30 }
  validates :description, :short_description, :city, :country, presence: true
  validates :owner, presence: true, length: { maximum: 30 }
  validates :street, presence: true, length: { maximum: 30 }
  validates :house_number, :postal_code, numericality: { only_integer: true }, length: { maximum: 4 } 
  validates :sms_keyword, presence: true, uniqueness: { case_sensitive: false }
  validates :phone, presence: true, length: { maximum: 8 }


  geocoded_by :address
  after_validation :geocode
  
  #Used by GeoCoder
  def address
    return street + " " + house_number + " " + postal_code + " " + city + " Denmark"
  end

  def map_address
    return street + " " + house_number + ", " + postal_code + " " + city
  end

  #Used by Gmaps4Rails
  def gmaps4rails_address
    address
  end

  acts_as_gmappable :address => "address", :process_geocoding => false
end
