class Member < ActiveRecord::Base
  attr_accessible :name, :postal_code, :gender, :birthday, :phone, :terms_of_service

  has_one :user, :as => :sub


  validates :name, presence: true, length: { maximum: 40 }
  validates :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }
  validates :gender, :inclusion => { :in => %w( W M ) }
  validates :birthday, presence: true
  validates :phone, numericality: { only_integer: true }, length: { maximum: 8 }
  validates :terms_of_service, :inclusion => { :in => [true, false] }
end
