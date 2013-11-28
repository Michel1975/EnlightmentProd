class WelcomeOffer < ActiveRecord::Base
  attr_accessible :description, :active

  belongs_to :merchant_store
  attr_accessor :message

  validates :merchant_store_id, :description, presence: true
  #validates :description, length: { maximum: 160 }

  #Custom method for validating message length due to dynamic contents
  validate :validate_message_length
  validates :active, :inclusion => { :in => [true, false] }

  #Used for sms messages - with regards section including store link.
  def message
    self.description = self.description + merchant_store.store_regards
  end

  def validate_message_length
    text_limit = 160 - merchant_store.store_regards.length
    result = true
    if self.description.present?
      if self.description.length > text_limit
        result = false
    end
    return result
  end

end#end class
