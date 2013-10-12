class Member < ActiveRecord::Base
  attr_accessible :name, :postal_code, :gender, :birthday, :phone, :terms_of_service, :origin, :user_attributes
  has_one :user, :as => :sub
  accepts_nested_attributes_for :user
  has_many :subscribers 

  #Used to determine current validation_mode
  attr_accessor :validation_mode

  validates :name, presence: true, length: { maximum: 40 }, :unless => "validation_mode == 'store'"
  validates :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }, :unless => "validation_mode == 'store'"
  validates :gender, :inclusion => { :in => %w( W M ) }, :unless => "validation_mode == 'store'"
  validates :birthday, presence: true, :unless => "validation_mode == 'store'"
  validates :phone, presence: true, length: { maximum: 10 }
  validates :terms_of_service, :inclusion => { :in => [true, false] }, :unless => "validation_mode == 'store'"
  validates :complete, :inclusion => { :in => [true, false] }
  validates :origin, :inclusion => { :in => %w( web store ) }

end


# 3 modes: Signup, web og merchant