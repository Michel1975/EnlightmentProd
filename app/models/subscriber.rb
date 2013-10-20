class Subscriber < ActiveRecord::Base
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  
  attr_accessible :member_id, :start_date, :cancel_date

  has_many :campaign_members #no dependent destroy due to historic campaign tracking for merchant
  belongs_to :merchant_store #Only custom counter cache
  belongs_to :member

  #Custom counter cache for active subscribers
  after_save :after_save
  after_destroy :after_destroy

  validates :merchant_store_id, :member_id, :start_date,  presence: true
  validates :active, :inclusion => { :in => [ true, false ] }

  def self.chart_data(start_date = 2.weeks.ago)
    total_subscribers = subscribers_by_day(start_date)
    (start_date.to_date..Date.today).map do |date|
      {
        created_date: date,
        total: total_subscribers[date] || 0
      }
    end
  end

  def self.subscribers_by_day(start_date)
    subscribers = Subscriber.where(created_at: start_date.beginning_of_day..Time.zone.now)
    subscribers = subscribers.group("created_date")
    subscribers = subscribers.select("date(created_at) as created_date, count(id) as total")
    subscribers.each_with_object({}) do |subscriber, totals|
      totals[subscriber.created_date.to_date] = subscriber.total
    end
  end

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
  		return (self.start_date.to_date - self.cancel_date.to_date).to_i > 90
  	end
  end

  def opt_out_link
  	client = Bitly.client
  	return "Stop:" + client.shorten("http://www.clubnovus.dk/stop_sms_confirm?token#{member.access_key}&#{member.id}&#{merchant_store.id}").short_url
  end

  #Custom counter cache - note that counter cache is not displayed next to merchant_store above
  #http://blog.douglasfshearer.com/post/17495285851/custom-counter-cache-with-conditions
  def after_save
      self.update_counter_cache
  end

  def after_destroy
      self.update_counter_cache
  end

  def update_counter_cache
      self.merchant_store.subscribers_count = Subscriber.count( :conditions => { :active => true, :merchant_store_id => self.merchant_store.id} )
      self.merchant_store.save(validate: false)
  end

end#end class
