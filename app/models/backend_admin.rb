class BackendAdmin < ActiveRecord::Base
  attr_accessible :name, :role, :user_attributes

  has_one :user, :as => :sub, dependent: :destroy
  accepts_nested_attributes_for :user

  validates :name, :role, :admin, presence: true
  validates :name, length: { maximum: 40 }, :allow_blank => true
  validates :role, :inclusion => { :in => %w( admin normal ) }, :allow_blank => true
  validates :admin, :inclusion => { :in => [true, false] }, :allow_blank => true
end
