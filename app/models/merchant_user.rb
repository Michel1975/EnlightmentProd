class MerchantUser < ActiveRecord::Base
  attr_accessible :name, :role, :phone, :user_attributes

  has_one :user, :as => :sub, dependent: :destroy
  accepts_nested_attributes_for :user

  belongs_to :merchant_store
  before_save :convert_phone_standard

  validates :name, :role, presence: true
  validates :phone, presence: true
  validate :validate_phone_format
  validates :admin, :inclusion => { :in => [true, false] }

  def login_as(merchant_store_id)
    self.merchant_store_id = merchant_store_id
  end

  private
    def convert_phone_standard
      self.phone = SMSUtility::SMSFactory.convert_phone_number(self.phone)
    end
    
    def validate_phone_format
      if !self.phone.blank? && !SMSUtility::SMSFactory.validate_phone_number_incoming?(self.phone) && (self.phone.length <= 12)
        errors.add(:phone, I18n.t(:invalid_phone, :scope => [:business_validations, :backend, :merchant_user]) )
      end
    end

end
