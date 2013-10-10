class Offer < ActiveRecord::Base
  scope :active, lambda {where("valid_from <= ? and valid_to <= ?", Time.zone.now, Time.zone.now ) }
  scope :completed, lambda {where("valid_to < ?", Time.zone.now ) }
  scope :scheduled, lambda {where("valid_from > ?", Time.zone.now ) }
  
  attr_accessible :title, :description, :offer_picture, :offer_picture_size, :valid_from, :valid_to, :remove_offer_picture
  mount_uploader :offer_picture, ImageUploader
  belongs_to :merchant_store
  
  validates :title, :length => { :maximum => 30}
  validates :description, :valid_from, :valid_to, :merchant_store_id, presence: true
end
