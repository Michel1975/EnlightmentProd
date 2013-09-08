class EventHistory < ActiveRecord::Base
  attr_accessible :description, :merchant_store_id, :type
end
