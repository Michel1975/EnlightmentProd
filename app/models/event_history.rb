class EventHistory < ActiveRecord::Base
  attr_accessible :description, :event_type

  belongs_to :merchant_store

  validates :event_type, :inclusion => { :in => %w(login logout opt-in-subscriber opt-out-subscriber campaign-created campaign-rescheduled campaign-cancelled campaign-finished )}
  validates :description, :merchant_store_id, presence: true
end
