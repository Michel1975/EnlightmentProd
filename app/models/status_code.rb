class StatusCode < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :message_notifications
end
