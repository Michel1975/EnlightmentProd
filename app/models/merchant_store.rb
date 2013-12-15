class MerchantStore < ActiveRecord::Base
  attr_accessible :store_name, :email, :active, :description, :short_description, :owner, :phone, :street, :house_number, :postal_code, :city, :country, :latitude, :longitude, :sms_keyword, :business_hours_attributes, :image_attributes, :qr_image_attributes
  #attr_reader :subscribers_count
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)

  has_one :image, :as => :imageable, dependent: :destroy
  has_one :qr_image, :as => :qrimageable, dependent: :destroy
  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :qr_image
  
  has_one :welcome_offer, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :business_hours, dependent: :destroy
  has_many :subscriber_histories, dependent: :destroy
  has_many :message_notifications, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_one  :subscription_plan, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :event_histories, dependent: :destroy
  has_many :merchant_users, dependent: :destroy
  has_many :subscribers, dependent: :destroy
  has_many :members, :through => :subscribers
  accepts_nested_attributes_for :business_hours

  before_save { |store| store.sms_keyword = store.sms_keyword.downcase } #af hensyn til match-forespørgsler ved sms-tilmelding
  before_save :convert_phone_standard

  validates :email, :store_name, :city, :country, :description, :short_description, :owner, :street, :house_number, :postal_code, :sms_keyword, :phone, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, :allow_blank => true
  validates :active, :inclusion => { :in => [ true, false ] }, :allow_blank => true
  
  validates :store_name, length: { maximum: 40 }, :allow_blank => true
  validates :description, length: { maximum: 500 }, :allow_blank => true
  validates :short_description, length: { maximum: 255 }, :allow_blank => true
  validates :owner, length: { maximum: 30 }, :allow_blank => true
  validates :street, length: { maximum: 30 }, :allow_blank => true
  validates :house_number, :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }, :allow_blank => true
  validates :sms_keyword, uniqueness: { case_sensitive: false }
  
  #We automatically convert to standard phone with +45 prefix
  validates :phone, length: { maximum: 12 }, :allow_blank => true
  validate :validate_phone_standard

  #Geocode fields
  geocoded_by :address
  after_validation :geocode

  #Map positioning coordinates
  acts_as_gmappable :address => "address", :process_geocoding => false

  def validate_monthly_message_limit?(message_count)
    return result = (self.message_notifications.month_total_messages.count + message_count) <= SMSUtility::STORE_TOTAL_MESSAGES_MONTH.to_i
  end
  
  #Bit.ly link for store link
  def store_link
    client = Bitly.client
    store_link = "#{ENV['PORTAL_LINK']}/display_store/#{self.id}"
    return "\nButik:" + client.shorten( store_link ).short_url
  end

  #Store regards
  def store_regards
    return "\nMvh\n" + self.store_name + store_link
  end

  #Used only when using static stop link instead of unique bitly links. 
  def static_stop_link
    return "\nStop: Svar STOP #{self.sms_keyword}"
  end
  
  def self.search(city, store_name)
    if city !="" && store_name !=""
      where("city ILIKE ? AND store_name ILIKE ? AND active = true", "%#{city.downcase}%", "%#{store_name.downcase}%")
    elsif city !="" && store_name == ""
      where('city ILIKE ? AND active = true', "%#{city.downcase}%")
    elsif city =="" && store_name !=""
      where('store_name ILIKE ? AND active = true', "%#{store_name.downcase}%")
    else
      #To avoid null pointer exceptions
      return Array.new
    end
  end

  #Create default business hours - to be used in form_for statements in admin backend
  def build_default_business_hours(n = 7)
    if (business_hours.size == 0)
      #Create business hours
        n.times do |n|
          weekday = (Date.today.beginning_of_week + n)
          if n == 6
            #To-Do: Create setter/getter which saves and retrives the right format when creating new store
            business_hours.build(day: (n+1), day_text: I18n.l(weekday, :format => "%A"), closed: true, open_time: Time.new(2013, 8, 29, 8, 30, 0).try(:strftime, "%H:%M"), close_time: Time.new(2013, 8, 29, 16, 30, 0).try(:strftime, "%H:%M"))
          else
            #To-Do: Create setter/getter which saves and retrives the right format when creating new store
            business_hours.build(day: (n+1), day_text: I18n.l(weekday, :format => "%A"), closed: false, open_time: Time.new(2013, 8, 29, 8, 30, 0).try(:strftime, "%H:%M"), close_time: Time.new(2013, 8, 29, 16, 30, 0).try(:strftime, "%H:%M"))
          end
        end
    end
    self 
  end

  #Used by GeoCoder to get latitude and longitude
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

  private
    def convert_phone_standard
      self.phone = SMSUtility::SMSFactory.convert_phone_number(self.phone)
    end
    
    def validate_phone_standard
      if !self.phone.blank? && !SMSUtility::SMSFactory.validate_phone_number_incoming?(self.phone)
        errors.add(:phone, I18n.t(:invalid_phone, :scope => [:business_validations, :merchant_store]) )
      end
    end
end
