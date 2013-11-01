class Image < ActiveRecord::Base
  attr_accessible :picture, :size, :picture_cache
  belongs_to :imageable, :polymorphic => true
  mount_uploader :picture, ImageUploader
end