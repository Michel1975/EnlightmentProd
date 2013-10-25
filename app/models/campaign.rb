class Campaign < ActiveRecord::Base
  scope :completed, where(:status => 'completed')
  scope :scheduled, where(:status => 'scheduled')
  attr_accessible :title, :message, :status, :activation_time, :message_group_id

  belongs_to :merchant_store
  has_many :campaign_members, dependent: :destroy
  before_create :generate_message_group 
  before_save :calculate_cost

  validates :title, presence: true, length: { maximum: 30 }
  validates :message, presence: true, length: { maximum: 160 }
  #Custom check of sms-message
  validate  :sms_compliance_validation
  validates :activation_time, presence: true
  validates :status, :inclusion => { :in => %w(scheduled error finished)}, :allow_blank => true
  validates :merchant_store_id, presence: true
  
  private
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
