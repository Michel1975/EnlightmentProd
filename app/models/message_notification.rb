class MessageNotification < ActiveRecord::Base
  scope :campaign, where(:notification_type => 'campaign')
  scope :single, where(:notification_type => 'single')
  scope :store, where("notification_type = ? OR notification_type = ?", 'campaign', 'single')

  #Default scopes for message limits
  #http://stackoverflow.com/questions/8197888/how-to-find-records-created-this-month-in-rails-3-1
  scope :month_total_messages, lambda { where( :created_at => Date.today.beginning_of_month..Date.today.end_of_month) }
  
  attr_accessible :recipient, :status_code_id, :notification_type, :message_id, :campaign_group_id, :merchant_store_id

  #Vi nøjes med standard implementeringen indtil videre, idet vi ikke behøver conditions på optællingen
  belongs_to :merchant_store, counter_cache: true
  belongs_to :status_code 
  
  validates :recipient, presence: true, length: { maximum: 12 }
  validates :status_code_id, presence: true
  validates :message_id, presence: true
  validates :message_id, uniqueness: { case_sensitive: false }, :allow_nil => true
  validates :notification_type, :inclusion => { :in => %w( campaign single admin )}
end
