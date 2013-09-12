class Campaign < ActiveRecord::Base
  attr_accessible :title, :message, :status, :activation_time, :instant_activation, :message_group_id 

  belongs_to :merchant_store
  has_many :campaign_members, dependent: :destroy

  validates :title, presence: true, length: { maximum: 30 }
  validates :message, presence: true, length: { maximum: 160 }
  validates :activation_time, presence: true, :unless Proc.new { |a| a.instant_activation?}
  validates :instant_activation, :inclusion => { :in => [ true, false ] }
  validates :message_group_id, :merchant_store_id, presence: true

end
