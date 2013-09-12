class BusinessHour < ActiveRecord::Base
  attr_accessible :day, :open_time, :close_time

  belongs_to :merchant_store

  validates :day, :open_time, :close_time, :merchant_store_id, presence: true
end
