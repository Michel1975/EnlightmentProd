class BusinessHour < ActiveRecord::Base
  attr_accessible :close_time, :day, :merchant_store_id, :open_time

  belongs_to :merchant_store
end
