class SubscriptionPlan < ActiveRecord::Base
  attr_accessible :start_date, :cancel_date, :subscription_type_id

  belongs_to :merchant_store
  belongs_to :subscription_type

  validates :merchant_store_id, :subscription_type_id, :start_date, presence: true
  validates :active, :inclusion => { :in => [true, false] }
end
