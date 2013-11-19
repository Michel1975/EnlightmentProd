class Merchant::DashboardsController < Merchant::BaseController
    
    #Note om tidszoner: http://www.elabs.se/blog/36-working-with-time-zones-in-ruby-on-rails
    #Link til charts-kode fra episode223: https://github.com/railscasts/223-charts-graphs-revised
	def store_dashboard
        logger.info "Loading store_dashboard action"
    	@merchant_store = current_merchant_store
        logger.debug "Merchant_store attributes hash: #{@merchant_store.attributes.inspect}"
        
        #Calling custom cache
        @recent_subscriber_data = Subscriber.chart_data(14.day.ago, @merchant_store, "day")
        logger.debug "Recent subscriber data: #{@recent_subscriber_data.inspect}"
        #To-Do: Skal ændres til group by month når postgress installeres på lokal maskine
        @months_subscriber_data = Subscriber.chart_data(16.weeks.ago, @merchant_store, "month")
        logger.debug "Monthly subscriber data: #{@months_subscriber_data.inspect}"

        #Diverse medlemsstatistikker
    	@active_subscribers_count = @merchant_store.subscribers_count
        logger.debug "Active subscribers count: #{@active_subscribers_count.inspect}"
    	date_range = (Date.today - 14.day)..Date.today
    	@opt_outs_last_14_days = @merchant_store.subscribers.inactive.where(:cancel_date => date_range).count
        logger.debug "Opt-outs 14 days: #{@opt_outs_last_14_days.inspect}"
    	@new_subscribers_last_14_days = @merchant_store.subscribers.active.where(:start_date => date_range).count
        logger.debug "New subscribers 14 days: #{@new_subscribers_last_14_days.inspect}"
    	
        #Tilbud
    	@active_offers = @merchant_store.offers.active.count
        logger.debug "Active offers count: #{@active_offers.inspect}"
    	#@scheduled_offers = @merchant_store.offers.scheduled.count
    	#@completed_offers = @merchant_store.offers.completed.count
    	
        #Kampagner
        @scheduled_campaigns = @merchant_store.campaigns.scheduled.count
        logger.debug "Scheduled campaigns count: #{@scheduled_campaigns.inspect}"

    	@completed_campaigns = @merchant_store.campaigns.completed.count
        logger.debug "Completed campaigns count: #{@completed_campaigns.inspect}"

        #SMS-beskeder ialt
        @total_sms_messages = @merchant_store.message_notifications.length #.month_total_messages.size
        logger.debug "Total sms messages count: #{@total_sms_messages.inspect}"

        #SMS beskeder denne måned
        #@total_sms_messages_campaign = @merchant_store.message_notifications.month_total_messages.length #.month_total_messages.size
        #@total_sms_messages_single = @merchant_store.message_notifications.month_total_messages.single.length #.month_total_messages.size
        #@total_sms_messages_test = @merchant_store.message_notifications.month_total_messages.test.length #.month_total_messages.size

        #Gns. daglig medlemstilgang
        @opt_outs_total = @merchant_store.subscribers.inactive.count
        logger.debug "Opt-outs total: #{@opt_outs_total.inspect}"

        #Activity feed with paginate functionality
        @activity_feeds = @merchant_store.event_histories.page(params[:page]).per_page(10)
        logger.debug "Activity feed page: #{@activity_feeds.inspect}"
  	end
end
