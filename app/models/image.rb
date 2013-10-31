class Image < ActiveRecord::Base
  attr_accessible :picture, :size
  belongs_to :imageable, :polymorphic => true
  mount_uploader :picture, ImageUploader
end