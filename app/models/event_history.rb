class EventHistory < ActiveRecord::Base
  attr_accessible :description, :merchant_store_id, :type

  belongs_to :merchant_store
end
