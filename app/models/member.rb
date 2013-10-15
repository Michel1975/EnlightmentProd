class Member < ActiveRecord::Base
  attr_accessible :name, :postal_code, :gender, :birthday, :phone, :terms_of_service, :origin, :user_attributes
  has_one :user, :as => :sub
  accepts_nested_attributes_for :user
  has_many :subscribers 
  before_save :convert_phone_standard
  #Used to determine current validation_mode
  attr_accessor :validation_mode
  #http://rubular.com

  #Vi antager at telefonnumre indtastet via forms fylder max. 8 tegn og automatisk opdateres med +45 før oprettelse. 
  #Sidstnævnte skal ske med client-side validering.

  validates :name, presence: true, length: { maximum: 40 }, :unless => "validation_mode == 'store'"
  validates :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }, :unless => "validation_mode == 'store'"
  validates :gender, :inclusion => { :in => %w( W M ) }, :unless => "validation_mode == 'store'"
  validates :birthday, presence: true, :unless => "validation_mode == 'store'"
  validates :phone, presence: true, length: { maximum: 12}
  validate  :validate_phone_standard
  validates :terms_of_service, :inclusion => { :in => [true, false] }, :unless => "validation_mode == 'store'"
  validates :complete, :inclusion => { :in => [true, false] }
  validates :origin, :inclusion => { :in => %w( web store ) }

  private
    def convert_phone_standard
      self.phone = SMSUtility::SMSFactory.convert_phone_number(self.phone)
    end

    def validate_phone_standard
      return SMSUtility::SMSFactory.validate_phone_number_incoming?(self.phone)
    end

end#end class


