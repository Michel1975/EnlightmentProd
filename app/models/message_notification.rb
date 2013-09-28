class MessageNotification < ActiveRecord::Base
  attr_accessible :recipient, :status_code_id, :type, :message_id, :message_group_id

  belongs_to :merchant_store
  belongs_to :status_code
  
  validates :recipient, presence: true, length: { maximum: 8 }
  validates :status_code_id, :merchant_store_id, presence: true
  validates :message_id, uniqueness: { case_sensitive: false }, :allow_nil => true
  validates :type, :inclusion => { :in => %w( single campaign system )}
end
