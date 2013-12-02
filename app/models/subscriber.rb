class Subscriber < ActiveRecord::Base
  attr_accessible :member_id, :start_date

  has_many :campaign_members #no dependent destroy due to historic campaign tracking for merchant
  belongs_to :merchant_store, counter_cache: true 
  belongs_to :member

  #Update subscriber history on sign_up and sign_out
  after_create :after_create_subscriber
  before_destroy :before_destroy_subscriber

  validates :merchant_store_id, :member_id, :start_date,  presence: true
  
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
    #Two modes: Specific store or entire network (backend)
    if merchant_store.present?
      subscribers = Subscriber.where(created_at: start_date.beginning_of_day..Time.zone.now, merchant_store_id: merchant_store.id)
    else
      subscribers = Subscriber.where(created_at: start_date.beginning_of_day..Time.zone.now) 
    end
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
        #logger.debug("Michel-loggy99: #{subscriber.created_month}: #{subscriber.total}: " + I18n.l(subscriber.created_month.to_date, :format => "%B") )
        totals[ I18n.l( subscriber.created_month.to_date, :format => "%B") ] = subscriber.total
      end 
    end
  end

  def self.opt_outs_by_period(start_date, merchant_store, mode)
    #Two modes: Specific store or entire network (backend)
    if merchant_store.present?
      opt_outs = Subscriber.where(cancel_date: start_date.beginning_of_day..Time.zone.now, merchant_store_id: merchant_store.id)
    else
      opt_outs = Subscriber.where(cancel_date: start_date.beginning_of_day..Time.zone.now)
    end

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

  def eligble_welcome_present?
    #Three month sleep period with no welcome present
    result = self.merchant_store.subscriber_histories.where("created_at >=? AND member_phone=?", (Time.zone.now - 90.days), self.member.try(:phone) )
    Rails.logger.debug("Result from Eligble_welcome_present: #{result.inspect}")
    #when this methid is called in signup logic, the subscriber is already created, so at least one history entry exist. This entry is ignored of-course.
    return result.size <= 1 ? true : false
  end

  def opt_out_link
  	client = Bitly.client
    #No new-line since link is inserted with stop macro
  	return "Stop:" + client.shorten("http://www.clubnovus.dk/stop_sms_confirm?token#{member.access_key}&#{member.id}&#{merchant_store.id}").short_url
  end

  def opt_out_link_sms 
    #client = Bitly.client
    #No new-line since link is inserted with stop macro
    return "Stop: send #{merchant_store.sms_keyword} til 1276 222" 
  end

  #Updates eventhistory for subscriber - for reporting purposes
  def after_create_subscriber
      self.merchant_store.subscriber_histories.create(event_type: "sign_up", member_id: self.member_id )
  end

  def before_destroy_subscriber
    self.merchant_store.subscriber_histories.create(event_type: "sign_out", member_id: self.member_id )   
  end

  #Custom counter cache - note that counter cache is not displayed next to merchant_store above
  #http://blog.douglasfshearer.com/post/17495285851/custom-counter-cache-with-conditions
  #def after_save
      #self.update_counter_cache
  #end

  #def after_destroy
      #self.update_counter_cache
  #end

  #def update_counter_cache
      #self.merchant_store.subscribers_count = Subscriber.count( :conditions => { :active => true, :merchant_store_id => self.merchant_store.id} )
      #self.merchant_store.save(validate: false)
  #end

end#end class
