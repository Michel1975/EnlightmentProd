class Campaign < ActiveRecord::Base
  scope :completed, where(:status => 'completed')
  scope :scheduled, where(:status => 'scheduled')
  attr_accessible :title, :message, :status, :activation_time, :message_group_id, :start_date, :start_time
  attr_writer :start_date, :start_time

  belongs_to :merchant_store
  has_many :campaign_members, dependent: :destroy
  after_initialize :set_default_activation_time
  before_create :generate_message_group 
  before_create :calculate_cost
  
  before_save :save_activation_time

  validates :title, presence: true, length: { maximum: 30 }
  validates :message, presence: true, length: { maximum: 160 }
  
  #Custom check of sms-message
  validate  :sms_compliance_validation
  validates :activation_time, presence: true
  validate :validate_activatation_time
  validates :status, :inclusion => { :in => %w( new scheduled error completed)}, :allow_blank => true
  validates :merchant_store_id, presence: true

  def start_date
   @start_date || activation_time.try(:strftime, "%d-%m-%Y")
  end

  def start_time
    @start_time || activation_time.try(:strftime, "%H:%M:%S")
  end

  private
    def save_activation_time
      self.activation_time = Time.zone.parse(@start_date + " " + @start_time )
    end

    def set_default_activation_time
      self.activation_time ||= Time.zone.now + 3.hour
    end

    def validate_activatation_time
      #earliest = Time.zone.now + 2.hour
      #latest = Time.zone.now + 7.days + 2.hour
      earliest = Time.zone.now + 1.hour
      latest = Time.zone.now + 1.days
      if self.activation_time.present?
        if (self.activation_time < earliest) && (self.activation_time < latest) 
          errors.add(:activation_time, I18n.t(:invalid_activation_time, earliest: I18n.l(earliest), latest: I18n.l(latest), :scope => [:business_validations, :campaign]) )
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
