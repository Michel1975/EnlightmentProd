class Member < ActiveRecord::Base
  attr_accessible :birthday, :gender, :name, :phone, :postal_code

  #has_one :user, as: => :sub

end
