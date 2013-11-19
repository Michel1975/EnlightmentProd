class QrImage < ActiveRecord::Base
  attr_accessible :picture, :size, :picture_cache
  belongs_to :qrimageable, :polymorphic => true
  mount_uploader :picture, ImageUploader
end
