class Member < ActiveRecord::Base
  attr_accessible :name, :postal_code, :gender, :birthday, :phone, :terms_of_service, :user_attributes
  has_one :user, :as => :sub
  accepts_nested_attributes_for :user
  has_many :subscribers


  validates :name, presence: true, length: { maximum: 40 }
  validates :postal_code, numericality: { only_integer: true }, length: { maximum: 4 }
  validates :gender, :inclusion => { :in => %w( W M ) }
  validates :birthday, presence: true
  validates :phone, numericality: { only_integer: true }, length: { maximum: 8 }
  validates :terms_of_service, :inclusion => { :in => [true, false] }
end
