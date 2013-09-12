class BackendAdmin < ActiveRecord::Base
  attr_accessible :name, :role

  has_one :user, :as => :sub

  validates :name, presence: true, length: { maximum: 40 }
  validates :role, :inclusion => { :in => %w( admin normal ) }
  validates :admin, :inclusion => { :in => [true, false] }
end
