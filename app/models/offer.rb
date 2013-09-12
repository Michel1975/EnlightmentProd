class Offer < ActiveRecord::Base
  attr_accessible :title, :description, :valid_from, :valid_to

  belongs_to :merchant_store

  validates :title, :length => { :maximum => 30}
  validates :description, :valid_from, :valid_to, :merchant_store_id, presence: true
end
