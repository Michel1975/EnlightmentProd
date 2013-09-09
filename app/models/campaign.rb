class Campaign < ActiveRecord::Base
  attr_accessible :activation_time, :instant_activation, :merchant_store_id, :message, :message_group_id, :status, :title

  belongs_to :merchant_store
  has_many :campaign_members, dependent: :destroy
end
