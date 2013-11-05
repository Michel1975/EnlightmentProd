class Member < ActiveRecord::Base
  include ActiveModel::Dirty
  attr_accessible :first_name, :last_name, :name, :postal_code, :city, :gender, :birthday, :phone, :terms_of_service, :origin, :user_attributes

  has_one :user, :as => :sub, dependent: :destroy
  accepts_nested_attributes_for :user
  has_many :subscribers 
  before_save :convert_phone_standard, :check_status, :name_convert
  before_save :check_member_status, :if => "self.status_changed?"


  #Used for completing profiles on web if they signed up in-store
  before_create :create_access_key
  #Used to determine current validation_mode
  attr_accessor :validation_mode
  #http://rubular.com
  #Vi antager at telefonnumre indtastet via forms fylder max. 8 tegn og automatisk opdateres med +45 før oprettelse. 
  #Sidstnævnte skal ske med client-side validering.
  validates :terms_of_service, :acceptance  => {:accept => true}, :unless => "validation_mode == 'store'"
  validates :first_name, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
  validates :last_name, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
  validates :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }, :unless => "validation_mode == 'store'"
  #validates :city, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
  validates :gender, :inclusion => { :in => %w( W M ) }, :unless => "validation_mode == 'store'"
  validates :birthday, presence: true, :unless => "validation_mode == 'store'"
  validates :phone, presence: true, length: { maximum: 12}, uniqueness: { case_sensitive: false }
  validate  :validate_phone_standard
  validates :terms_of_service, :inclusion => { :in => [true, false] }, :unless => "validation_mode == 'store'"
  validates :complete, :inclusion => { :in => [true, false] }
  validates :status, :inclusion => { :in => [true, false] }
  validates :origin, :inclusion => { :in => %w( web store ) }

  #This method is called in sms-utility before sending a message to subscriber
  def opt_out_link(merchant_store)
    client = Bitly.client
    client.shorten("http://www.clubnovus.dk?token={}&member_id=#{self.id}&merchant_store_id=#{merchant_store.id}")
  end

  private
    #Deactivate all memberships on merchant stores
    def check_member_status
      if self.status == false
        #To-do: self.deactivation_date = Time.zone.now
        subscribers.each do |subscriber|
          subscriber.opt_out
          subscriber.save
        end
      end
    end

    def name_convert
      self.name = self.first_name + " " + self.last_name
    end

    #Updates status to true when member completes his profile on web
    def check_status
      if !self.complete
        self.validation_mode = "web"
        if self.valid? && user !=nil
          self.complete = true
        end 
      end
    end

    def convert_phone_standard
      self.phone = SMSUtility::SMSFactory.convert_phone_number(self.phone)
    end

    #Not currently used - we implement later with client-side code
    def validate_phone_standard
      return SMSUtility::SMSFactory.validate_phone_number_incoming?(self.phone)
    end

    def create_access_key
      self.access_key ||= [id.to_s, SecureRandom.hex(5)].join
    end
    
end#end class


