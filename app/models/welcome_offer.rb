class WelcomeOffer < ActiveRecord::Base
  attr_accessible :description, :active

  belongs_to :merchant_store
  attr_accessor :message

  validates :merchant_store_id, :description, presence: true
  validates :description, length: { maximum: 160 }
  validates :active, :inclusion => { :in => [true, false] }

  #Used for sms messages - with regards section including store link.
  def message
    self.description = self.description + merchant_store.store_regards
  end

end
