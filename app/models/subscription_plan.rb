class SubscriptionPlan < ActiveRecord::Base
  attr_accessible :active, :cancel_date, :merchant_store_id, :start_date, :subscription_type_id

  belongs_to :merchant_store
  belongs_to :subscription_type

end
