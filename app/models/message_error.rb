class MessageError < ActiveRecord::Base
  attr_accessible :text, :recipient, :error_type

  validates :error_type, :inclusion => { :in => %w( invalid_keyword invalid_phone_number missing_attributes )}, :allow_blank => true
end
