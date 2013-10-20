class Merchant::DashboardsController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
    
    #Note om tidszoner: http://www.elabs.se/blog/36-working-with-time-zones-in-ruby-on-rails
    #Link til charts-kode fra episode223: https://github.com/railscasts/223-charts-graphs-revised
	def store_dashboard
    	@merchant_store = current_merchant_store
        #Calling custom cache
        @active_subscribers = Subscriber.chart_data(2.day.ago)
    	@active_subscribers_count = @merchant_store.subscribers_count
    	date_range = (Date.today - 14.day)..Date.today
    	@opt_outs_last_14_days = @merchant_store.subscribers.inactive.where(:cancel_date => date_range).count
    	@new_subscribers_last_14_days = @merchant_store.subscribers.active.where(:start_date => date_range).count
    	#Tilbud
    	@active_offers = @merchant_store.offers.active.count
    	@scheduled_offers = @merchant_store.offers.scheduled.count
    	@completed_offers = @merchant_store.offers.completed.count
    	#Kampagner
    	@completed_campaigns = @merchant_store.campaigns.completed.count
    	@scheduled_campaigns = @merchant_store.campaigns.scheduled.count

        #SMS messages
        @total_sms_messages = @merchant_store.message_notifications.month_total_messages.length#.month_total_messages.size
  	end
end
