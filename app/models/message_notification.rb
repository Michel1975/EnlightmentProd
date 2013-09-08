class MessageNotification < ActiveRecord::Base
  attr_accessible :merchant_store_id, :message_group_id, :message_id, :recipient, :status_code_id, :type
end
