class StatusCode < ActiveRecord::Base
  attr_accessible :name, :description

  has_many :message_notifications

  validates :name, :description, presence: true
end
