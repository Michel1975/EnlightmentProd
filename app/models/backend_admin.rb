class BackendAdmin < ActiveRecord::Base
  attr_accessible :admin, :name, :role

  has_one :user, as: => :sub
end
