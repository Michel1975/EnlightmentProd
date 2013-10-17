class Subscriber < ActiveRecord::Base
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  
  attr_accessible :member_id, :start_date, :cancel_date

  has_many :campaign_members #no dependent destroy due to historic campaign tracking for merchant
  belongs_to :merchant_store
  belongs_to :member

  validates :merchant_store_id, :member_id, :start_date,  presence: true
  validates :active, :inclusion => { :in => [ true, false ] }

  def signup
  	self.active = true
  	self.start_date = Time.zone.now
  end

  def opt_out
  	self.active = false
  	self.cancel_date = Time.zone.now
  end

  def eligble_welcome_present?
  	if self.cancel_date.blank? 
  		return true
  	else
  		#To avoid abuse, there is a 90 days sleep period in which no welcome present is sent.
  		return (self.start_date.to_date - self.cancel_date.to_date).to_i < 90
  	end
  end

  def opt_out_link
  	client = Bitly.client
  	return "Stop:" + client.shorten("http://www.clubnovus.dk/stop_sms_confirm?token#{member_access_key}&#{member.id}&#{merchant_store.id}")
  end

end#end class
