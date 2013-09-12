class SubscriptionType < ActiveRecord::Base
  attr_accessible :name, :monthly_price

  has_many :subscription_plans

  validates :name, presence: true
  validates :monthly_price, numericality: true
end
