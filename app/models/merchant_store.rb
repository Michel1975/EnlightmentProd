class MerchantStore < ActiveRecord::Base
  attr_accessible :active, :city, :country, :description, :house_number, :latitude, :longitude, :owner, :postal_code, :sms_keyword, :store_name, :street
end
