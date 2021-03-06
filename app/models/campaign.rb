class Campaign < ActiveRecord::Base
  scope :completed, where(:status => 'completed')
  scope :scheduled, where(:status => 'scheduled')
  attr_accessible :title, :message, :status, :activation_time, :message_group_id, :start_date, :start_time, :acknowledgement
  attr_writer :start_date, :start_time

  belongs_to :merchant_store
  has_many :campaign_members, dependent: :destroy
  after_initialize :set_default_activation_time
  before_create :generate_message_group 
  before_create :calculate_cost

  #Customers must only pay for sent messages - thus we delete if message entries if campaign is deleted.
  before_destroy :delete_message_notifications 
  
  before_save :set_default_status
  #Must be a before_validation callback - otherwise activation datetime is not set before validation
  before_validation :save_activation_time

  validates :title, presence: true, length: { maximum: 30 }
  validates :message, presence: true, length: { maximum: 160 }
  
  #Custom check of sms-message
  validate  :sms_compliance_validation
  validates :activation_time, presence: true
  validate  :validate_activation_time
  validates :status, :inclusion => { :in => %w( new scheduled gateway_confirmed status_retrived_once completed error)}, :allow_blank => true
  validates :merchant_store_id, presence: true
  validates :acknowledgement, :acceptance  => {:accept => true}

  def start_date
    @start_date || activation_time.try(:strftime, "%d-%m-%Y")
  end

  def start_time
    @start_time || activation_time.try(:strftime, "%H:%M")
  end

  def self.search(from_date, to_date, status)
    if from_date !=""
      result = where("activation_time >= ?", Time.zone.parse(from_date).beginning_of_day )
    end

    if to_date !=""
      result = result.nil? ? where("activation_time <= ?", Time.zone.parse(to_date).end_of_day ) : result.where("activation_time <= ?", Time.zone.parse(to_date).end_of_day )
    end
    
    if status !=""
      result = result.nil? ? where("status = ?", status.downcase) : result.where("status = ?", status.downcase) 
    end

    #If no parameters are provided, we insert dummy values to ensure proper return type
    if from_date.blank? && to_date.blank? && status.blank?
      result = where("status = 'XXXX'")
    end
    return result
  end

  private
    def save_activation_time
      if @start_date && @start_time
        self.activation_time = Time.zone.parse(@start_date + " " + @start_time )
      end
    end

    #Default start time is 2 hours from now
    def set_default_activation_time
      self.activation_time ||= Time.zone.now + 2.hour
    end

    #Default status value is set to new
    def set_default_status
      self.status ||= 'new'
    end


    def validate_activation_time
      earliest = Time.zone.now + 1.hour
      latest = earliest + 5.days  
      if self.activation_time.present?
        if (self.activation_time < earliest) || (self.activation_time > latest) 
          errors.add(:activation_time, I18n.t(:invalid_activation_time, earliest: I18n.l(earliest), latest: I18n.l(latest), :scope => [:business_validations, :campaign]) )
        end
      end
    end

    def delete_message_notifications
      #If campaign is completed, we don't delete since we loose invoice tracking in message notification
      if self.status != "completed" 
        sms_message_entries = self.merchant_store.message_notifications.where(campaign_group_id: self.message_group_id)
        #Bulk delete in this situation
        if sms_message_entries.size != 0
          sms_message_entries.delete_all
        end
      end
    end

    def calculate_cost
      if self.campaign_members.size > 0
        self.total_cost = (self.campaign_members.size * 0.25)
      else
        self.total_cost = 0.0
      end
    end
    #def generate_message_group
      #self.message_group_id = SecureRandom.urlsafe_base64
    #end
    #Ny og mere sikker version fra http://railscasts.com/episodes/274-remember-me-reset-password

    def generate_message_group
      begin
        self.message_group_id ||= SecureRandom.urlsafe_base64
      end while Campaign.exists?(message_group_id: self.message_group_id)
    end

    def sms_compliance_validation
      if self.message != "" && !SMSUtility::SMSFactory.validate_sms?(self.message)
        errors.add(:message, I18n.t(:invalid_message, :scope => [:business_validations, :instant_subscriber_message]) )
      end
    end
end
