class Subscriber < ActiveRecord::Base
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  
  attr_accessible :member_id, :start_date, :cancel_date

  has_many :campaign_members #no dependent destroy due to historic campaign tracking for merchant
  belongs_to :merchant_store #Only custom counter cache
  belongs_to :member

  #Custom counter cache for active subscribers. After_destroy er med for en sikkerheds skyld selvom vi ikke sletter subscribers.
  after_save :after_save
  after_destroy :after_destroy

  validates :merchant_store_id, :member_id, :start_date,  presence: true
  validates :active, :inclusion => { :in => [ true, false ] }

  #To-Do: Group by month, når vi installerer postgress på lokal maskine.
  def self.chart_data(start_date = 2.weeks.ago, merchant_store, mode)
    total_new_subscribers = new_subscribers_by_period(start_date, merchant_store, mode)
    total_opt_outs = opt_outs_by_period(start_date, merchant_store, mode)
    if mode=="day"
      (start_date.to_date..Date.today).map do |date|
        {
          #Standard date format is applied using I18n
          date: I18n.l(date),
          no_new_members: total_new_subscribers[date] || 0,
          no_opt_outs: total_opt_outs[date] || 0
        }
      end
    else
      (start_date.to_date..Date.today).map(&:beginning_of_month).uniq.map do |month|
        {
          #Standard date format is applied using I18n
          month: I18n.l(month, :format => "%B"),
          no_new_members: total_new_subscribers[ I18n.l(month, :format => "%B") ] || 0,
          no_opt_outs: total_opt_outs[ I18n.l(month, :format => "%B") ] || 0
        }
      end
    end
  end

  def self.new_subscribers_by_period(start_date, merchant_store, mode)
    subscribers = Subscriber.where(created_at: start_date.beginning_of_day..Time.zone.now, merchant_store_id: merchant_store.id)
    if mode == "day"
      subscribers = subscribers.select("date(created_at) as created_date, count(id) as total")
      subscribers = subscribers.group("created_date")
      subscribers.each_with_object({}) do |subscriber, totals|
        totals[subscriber.created_date.to_date] = subscriber.total
      end
    else
      subscribers = subscribers.select("DATE_TRUNC('month', created_at) as created_month, count(id) as total")
      subscribers = subscribers.group("DATE_TRUNC('month', created_at)")
      subscribers.each_with_object({}) do |subscriber, totals|
        logger.debug("Michel-loggy99: #{subscriber.created_month}: #{subscriber.total}: " + I18n.l(subscriber.created_month.to_date, :format => "%B") )
        totals[ I18n.l( subscriber.created_month.to_date, :format => "%B") ] = subscriber.total
      end 
    end
  end

  def self.opt_outs_by_period(start_date, merchant_store, mode)
    opt_outs = Subscriber.where(cancel_date: start_date.beginning_of_day..Time.zone.now, merchant_store_id: merchant_store.id)
    if mode == "day"
      opt_outs = opt_outs.select("date(cancel_date) as cancel_date, count(id) as total")
      opt_outs = opt_outs.group("cancel_date")
      opt_outs.each_with_object({}) do |subscriber, totals|
        totals[subscriber.cancel_date.to_date] = subscriber.total
      end
    else
      opt_outs = opt_outs.select("DATE_TRUNC('month', cancel_date) as cancel_date, count(id) as total")
      opt_outs = opt_outs.group("DATE_TRUNC('month', cancel_date)")
      opt_outs.each_with_object({}) do |subscriber, totals|
        totals[ I18n.l( subscriber.cancel_date.to_date, :format => "%B")] = subscriber.total
      end
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
    #No new-line since link is inserted with stop macro
  	return "\nStop:" + client.shorten("http://www.clubnovus.dk/stop_sms_confirm?token#{member.access_key}&#{member.id}&#{merchant_store.id}").short_url
  end

  def opt_out_link_sms 
    client = Bitly.client
    #No new-line since link is inserted with stop macro
    return "\nStop: send #{merchant_store.sms_keyword} til 1276 222" 
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
