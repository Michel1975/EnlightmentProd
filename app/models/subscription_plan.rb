class SubscriptionPlan < ActiveRecord::Base
  attr_accessible :active, :cancel_date, :merchant_store_id, :start_date, :subscription_type_id
end
