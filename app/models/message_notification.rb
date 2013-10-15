class MessageNotification < ActiveRecord::Base
  attr_accessible :recipient, :status_code_id, :notification_type, :message_id, :merchant_store_id

  belongs_to :merchant_store
  belongs_to :status_code
  
  validates :recipient, presence: true, length: { maximum: 12 }
  validates :status_code_id, :merchant_store_id, presence: true
  validates :message_id, uniqueness: { case_sensitive: false }, :allow_nil => true
  validates :notification_type, :inclusion => { :in => %w( campaign single test)}
end
