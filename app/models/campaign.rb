class Campaign < ActiveRecord::Base
  attr_accessible :activation_time, :instant_activation, :merchant_store_id, :message, :message_group_id, :status, :title
end
