class Subscriber < ActiveRecord::Base
  attr_accessible :member_id, :merchant_store_id, :start_date
end
