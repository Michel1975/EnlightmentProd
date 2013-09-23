class WelcomeOffer < ActiveRecord::Base
  attr_accessible :description, :active

  belongs_to :merchant_store

  validates :merchant_store_id, :description, presence: true
  validates :active, :inclusion => { :in => [true, false] }

end
