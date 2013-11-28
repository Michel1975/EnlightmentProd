class SubscriberHistory < ActiveRecord::Base
	scope :sign_ups, where(:event_type => 'sign_up')
	scope :sign_outs, where(:event_type => 'sign_out')
	attr_accessible :event_type, :member_id

  #Store actual phone to prevent fraud when redeeming welcome present. See also eligble_welcome_present? in Subscriber
  before_save :save_phone

	validates :event_type, :inclusion => { :in => %w( sign_up sign_out ) }
	
  	#To-Do: Group by month, når vi installerer postgress på lokal maskine.
  	def self.chart_data(start_date = 2.weeks.ago, merchant_store, mode)
    	total_new_subscribers = new_subscribers_by_period(start_date, merchant_store, mode)
    	total_opt_outs = opt_outs_by_period(start_date, merchant_store, mode)
    	if mode == "day"
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
      		subscribers = SubscriberHistory.sign_ups.where(created_at: start_date.beginning_of_day..Time.zone.now, merchant_store_id: merchant_store.id)
    	else
      		subscribers = SubscriberHistory.sign_ups.where(created_at: start_date.beginning_of_day..Time.zone.now) 
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
      		opt_outs = SubscriberHistory.sign_outs.where(created_at: start_date.beginning_of_day..Time.zone.now, merchant_store_id: merchant_store.id)
    	else
      		opt_outs = SubscriberHistory.sign_outs.where(created_at: start_date.beginning_of_day..Time.zone.now)
    	end

    	if mode == "day"
      		opt_outs = opt_outs.select("date(created_at) as cancel_date, count(id) as total")
      		opt_outs = opt_outs.group("cancel_date")
      		opt_outs.each_with_object({}) do |subscriber, totals|
        		totals[subscriber.cancel_date.to_date] = subscriber.total
      	end
    	else
      		opt_outs = opt_outs.select("DATE_TRUNC('month', created_at) as cancel_date, count(id) as total")
      		opt_outs = opt_outs.group("DATE_TRUNC('month', created_at)")
      		opt_outs.each_with_object({}) do |subscriber, totals|
        		totals[ I18n.l( subscriber.cancel_date.to_date, :format => "%B")] = subscriber.total
      		end
    	end
  	end

    private
      #Save the phone number in clear text to ensure correct match based on actual phone number. Member_id is not safe since it might change.
      def save_phone
        member = Member.find_by_id(self.member_id)
        self.member_phone ||= member && member.phone
      end
end
