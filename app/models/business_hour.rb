class BusinessHour < ActiveRecord::Base
  attr_accessible :day, :day_text, :open_time, :close_time, :closed

  belongs_to :merchant_store

  validates :day, :day_text, :open_time, :close_time, :merchant_store_id, presence: true, :unless => "self.closed == 'true'"
  validates :closed, :inclusion => { :in => [true, false] }

  def opening_hour
  	if self.closed
  		return "Lukket"
  	else
  		return self.open_time.to_formatted_s(:time) + "=>" + self.close_time.to_formatted_s(:time)
  	end
  end

end
