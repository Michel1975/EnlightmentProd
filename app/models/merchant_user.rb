class MerchantUser < ActiveRecord::Base
  attr_accessible :name, :role, :phone, :user_attributes

  has_one :user, :as => :sub
  accepts_nested_attributes_for :user

  belongs_to :merchant_store
  before_save :convert_phone_standard

  validates :name, :role, :merchant_store_id, presence: true
  validates :phone, presence: true, length: { maximum: 12 }
  validates :admin, :inclusion => { :in => [true, false] }

  def login_as(merchant_store_id)
    self.merchant_store_id = merchant_store_id
  end

  private
    def convert_phone_standard
      self.phone = SMSUtility::SMSFactory.convert_phone_number(self.phone)
    end

    #Not currently used - we implement later with client-side code
    def validate_phone_standard
      return SMSUtility::SMSFactory.validate_phone_number_incoming?(self.phone)
    end
end
