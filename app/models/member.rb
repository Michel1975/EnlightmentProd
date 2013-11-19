class Member < ActiveRecord::Base
  include ActiveModel::Dirty
  scope :active, where(:status => true)
  scope :inactive, where(:status => false)
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
  validates :terms_of_service, :acceptance  => {:accept => true}, :unless => "validation_mode == 'store'", :on => :create #Skal kun accepteres ved oprettelse
  validates :first_name, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
  validates :last_name, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
  validates :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }, :unless => "validation_mode == 'store'"
  validates :city, presence: true, length: { maximum: 20 }, :unless => "validation_mode == 'store'"
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

  def self.search(search_name)
    if search_name !="" 
      where('name ILIKE ?', "%#{search_name.downcase}%")
    end
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

    #Token used as verification in shortened links with Bitly
    def create_access_key
      self.access_key ||= [id.to_s, SecureRandom.hex(5)].join
    end
    
end#end class


