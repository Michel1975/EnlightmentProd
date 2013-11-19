class MerchantStore < ActiveRecord::Base
  attr_accessible :store_name, :email, :active, :description, :short_description, :owner, :phone, :street, :house_number, :postal_code, :city, :country, :latitude, :longitude, :sms_keyword, :business_hours_attributes, :image_attributes, :qr_image_attributes
  #attr_reader :subscribers_count
  scope :active, where(:active => true)

  has_one :image, :as => :imageable, dependent: :destroy
  has_one :qr_image, :as => :qrimageable, dependent: :destroy
  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :qr_image
  
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

  before_save { |store| store.sms_keyword = store.sms_keyword.downcase } #af hensyn til match-forespørgsler ved sms-tilmelding
  before_save :convert_phone_standard

  validates :email, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, :allow_blank => true
  validates :active, :inclusion => { :in => [ true, false ] }
  validates :store_name, presence: true, length: { maximum: 40 }
  validates :city, :country, presence: true
  validates :description, presence: true, length: { maximum: 500 }
  validates :short_description, presence: true, length: { maximum: 255 }
  validates :owner, presence: true, length: { maximum: 30 }
  validates :street, presence: true, length: { maximum: 30 }
  validates :house_number, :postal_code, presence: true
  validates :house_number, :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }, :allow_blank => true
  validates :sms_keyword, presence: true, uniqueness: { case_sensitive: false }
  
  #We automatically convert to standard phone with +45 prefix
  validates :phone, presence: true, length: { maximum: 12 }

  #Geocode fields
  geocoded_by :address
  after_validation :geocode

  #Map positioning coordinates
  acts_as_gmappable :address => "address", :process_geocoding => false
  
  #Bit.ly link for sms
  def store_link
    client = Bitly.client
    return "\nButik:" + client.shorten("http://www.clubnovus.dk/display_store/#{self.id}").short_url
  end

  def store_regards
    return "\nMvh\n" + self.store_name + store_link
  end
  
  def self.search(city, store_name)
    if city !="" && store_name !=""
      where('city ILIKE ? AND store_name ILIKE ?', "%#{city.downcase}%", "%#{store_name.downcase}%")
    elsif city !="" && store_name = ""
      where('city ILIKE ?', "%#{city.downcase}%")
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

  def short_store_link
    #To-Do: Generate bitly link for store. This link should not be changed - maybe stored in database.
  end

  private
    def convert_phone_standard
      self.phone = SMSUtility::SMSFactory.convert_phone_number(self.phone)
    end

    #Not currently used - we implement later with client-side code
    def validate_phone_standard
      return SMSUtility::SMSFactory.validate_phone_number_incoming?(self.phone)
    end
end
