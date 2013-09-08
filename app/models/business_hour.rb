class BusinessHour < ActiveRecord::Base
  attr_accessible :close_time, :day, :merchant_store_id, :open_time
end
