class Merchant::DashboardsController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
    
    #Note om tidszoner: http://www.elabs.se/blog/36-working-with-time-zones-in-ruby-on-rails
    #Link til charts-kode fra episode223: https://github.com/railscasts/223-charts-graphs-revised
	def store_dashboard
    	@merchant_store = current_merchant_store
        #Calling custom cache
        @recent_subscriber_data = Subscriber.chart_data(14.day.ago, @merchant_store, "day")
        #To-Do: Skal ændres til group by month når postgress installeres på lokal maskine
        @months_subscriber_data = Subscriber.chart_data(12.weeks.ago, @merchant_store, "month")

        #Diverse medlemsstatistikker
    	@active_subscribers_count = @merchant_store.subscribers_count
    	date_range = (Date.today - 14.day)..Date.today
    	@opt_outs_last_14_days = @merchant_store.subscribers.inactive.where(:cancel_date => date_range).count
    	@new_subscribers_last_14_days = @merchant_store.subscribers.active.where(:start_date => date_range).count
    	
        #Tilbud
    	@active_offers = @merchant_store.offers.active.count
    	#@scheduled_offers = @merchant_store.offers.scheduled.count
    	#@completed_offers = @merchant_store.offers.completed.count
    	
        #Kampagner
        @scheduled_campaigns = @merchant_store.campaigns.scheduled.count
    	@completed_campaigns = @merchant_store.campaigns.completed.count

        #SMS-beskeder ialt
        @total_sms_messages_campaign = @merchant_store.message_notifications.length #.month_total_messages.size

        #SMS beskeder denne måned
        #@total_sms_messages_campaign = @merchant_store.message_notifications.month_total_messages.length #.month_total_messages.size
        #@total_sms_messages_single = @merchant_store.message_notifications.month_total_messages.single.length #.month_total_messages.size
        #@total_sms_messages_test = @merchant_store.message_notifications.month_total_messages.test.length #.month_total_messages.size

        #Gns. daglig medlemstilgang
        @opt_outs_total = @merchant_store.subscribers.inactive.count
  	end
end
