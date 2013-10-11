class Campaign < ActiveRecord::Base
  scope :completed, where(:status => 'completed')
  scope :scheduled, where(:status => 'scheduled')
  attr_accessible :title, :message, :status, :activation_time, :instant_activation, :message_group_id 

  belongs_to :merchant_store
  has_many :campaign_members, dependent: :destroy
  before_create :generate_message_group

  validates :title, presence: true, length: { maximum: 30 }
  validates :message, presence: true, length: { maximum: 160 }
  validates :activation_time, presence: true, :unless => Proc.new { |a| a.instant_activation?}
  validates :instant_activation, :inclusion => { :in => [ true, false ] }
  validates :status, :inclusion => { :in => %w(scheduled error finished)}, :allow_blank => true
  validates :merchant_store_id, presence: true

  
  private
    #def generate_message_group
      #self.message_group_id = SecureRandom.urlsafe_base64
    #end
    #Ny og mere sikker version fra http://railscasts.com/episodes/274-remember-me-reset-password
    def generate_message_group
      begin
        self.message_group_id = SecureRandom.urlsafe_base64
      end while Campaign.exists?(message_group_id: self.message_group_id)
    end
    
end
