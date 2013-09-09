class SubscriptionType < ActiveRecord::Base
  attr_accessible :monthly_price, :name

  has_many :subscription_plans
end
