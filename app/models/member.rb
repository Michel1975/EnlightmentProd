class Member < ActiveRecord::Base
  #include ActiveModel::Dirty
  apply_simple_captcha :message => "Koden du indtastede matcher ikke billed-koden", :add_to_base => true
  
  attr_accessible :first_name, :last_name, :name, :postal_code, :city, :gender, :birthday, :phone, :terms_of_service, :origin, :user_attributes, :captcha, :captcha_key

  has_one :user, :as => :sub, dependent: :destroy
  accepts_nested_attributes_for :user
  has_many :subscribers, dependent: :destroy
  before_save :convert_phone_standard, :check_status, :name_convert

  #Used for completing profiles on web if they signed up in-store
  before_create :create_access_key, :create_phone_confirmation_code
  #Used to determine current validation_mode
  
  attr_accessor :validation_mode
  #http://rubular.com
  #Vi antager at telefonnumre indtastet via forms fylder max. 8 tegn og automatisk opdateres med +45 før oprettelse. 
  #Sidstnævnte skal ske med client-side validering.
  validates :terms_of_service, :acceptance  => {:accept => true}, :unless => "validation_mode == 'store'", :on => :create #Skal kun accepteres ved oprettelse
  validates :first_name, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
  validates :last_name, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
  validates :postal_code, presence: true, :unless => "validation_mode == 'store'"
  validates :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }, :allow_blank => true, :unless => "validation_mode == 'store'"
  validates :city, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
  validates :gender, presence: true, :unless => "validation_mode == 'store'"
  validates :gender, :inclusion => { :in => %w( W M ) }, :allow_blank => true, :unless => "validation_mode == 'store'"
  validates :birthday, presence: true, :unless => "validation_mode == 'store'"
  validates :phone, presence: true, length: { maximum: 12}, uniqueness: { case_sensitive: false }
  validates :terms_of_service, :inclusion => { :in => [true, false] }, :unless => "validation_mode == 'store'"
  validates :complete, :inclusion => { :in => [true, false] }
  validates :origin, :inclusion => { :in => %w( web store ) }

  #Only necessary to validate in web scenarios since phone validation for in-store signups is handled in controller logic
  validate :validate_phone_format, :unless => "validation_mode == 'store'"
  validates_inclusion_of :birthday, :in => Date.new(1900)..Time.now.years_ago(18).to_date,
    :message => I18n.t(:invalid_birthday, :scope => [:business_validations, :frontend, :member_user]), :allow_blank => true, :unless => "validation_mode == 'store'"





  #This method is called in sms-utility before sending a message to subscriber
  def opt_out_link(merchant_store)
    client = Bitly.client
    client.shorten("#{ENV['PORTAL_LINK']}/stop_sms_confirm?token={self.access_key}&member_id=#{self.id}&merchant_store_id=#{merchant_store.id}")
  end

  #This method is called to provide email confirmation email for web-signups
  def confirm_email_link
    link = "#{ENV['PORTAL_LINK']}/confirm_email?token=#{self.access_key}&email=#{self.user.email}"
  end
  
  def self.search(search_name, phone_number)
    if search_name !="" 
      result = where('name ILIKE ?', "%#{search_name.downcase}%")
    end

    if phone_number !=""
      phone_number = SMSUtility::SMSFactory.convert_phone_number(phone_number)
      result = result.nil? ? where("phone = ?", phone_number) : result.where("phone = ?", phone_number )
    end

    #If no parameters are provided, we insert dummy values to ensure proper return type
    if search_name.blank? && phone_number.blank?
      result = where("name = 'XXXX'")
    end
    return result
  end

  #To-Do: Group by month, når vi installerer postgress på lokal maskine.
  def self.chart_data(start_date = 2.weeks.ago)
    total_new_members = new_members_by_period(start_date)
      (start_date.to_date..Date.today).map do |date|
        {
          #Standard date format is applied using I18n
          date: I18n.l(date),
          no_new_members: total_new_members[date] || 0
        }
      end
  end

  def self.new_members_by_period(start_date)
    members = Member.where(created_at: start_date.beginning_of_day..Time.zone.now) 
    members = members.select("date(created_at) as created_date, count(id) as total")
    members = members.group("created_date")
    members.each_with_object({}) do |member, totals|
      totals[member.created_date.to_date] = member.total
    end
  end

  private
    def name_convert
      if self.first_name && self.last_name
        self.name = self.first_name + " " + self.last_name
      end
    end

    #Updates status to true when member completes his profile on web
    def check_status
      tmp_mode = self.validation_mode
      #Check if web profile is  
      if !self.complete
        self.validation_mode = "web"
        if self.valid? && user != nil
          self.complete = true
        end 
      end

      #Store profiles has automatically provided their permission on phone
      if self.origin == 'store' && !self.phone_confirmed 
        self.phone_confirmed = true
      end

      #Change back to original validation mode
      self.validation_mode = tmp_mode
    end

    def convert_phone_standard
      self.phone = SMSUtility::SMSFactory.convert_phone_number(self.phone)
    end

    #Used in member edit mode in web-portal
    def validate_phone_format
      if !SMSUtility::SMSFactory.validate_phone_number_incoming?(self.phone) && (self.phone.length <= 12)
        errors.add(:phone, I18n.t(:invalid_phone, :scope => [:business_validations, :frontend, :member_user]) )
      end
    end

    #Used in frontend to ensure that members are at least 18 years old
    def validate_birthday
      invalid_range = (Date.today - 18.years)..Date.today
      if self.birthday == invalid_range
        errors.add(:birthday, I18n.t(:invalid_birthday, :scope => [:business_validations, :frontend, :member_user]) )
      end
    end

    #Token used as verification in shortened links with Bitly
    def create_access_key
      self.access_key ||= [id.to_s, SecureRandom.hex(5)].join
    end

    #Used when confirming member phone for web profiles
    def create_phone_confirmation_code
      self.phone_confirmation_code ||= Random.rand(1000..9999)
    end
    
end#end class


