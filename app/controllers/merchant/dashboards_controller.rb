class Merchant::DashboardsController < Merchant::BaseController
	
	#Note om tidszoner: http://www.elabs.se/blog/36-working-with-time-zones-in-ruby-on-rails
	def store_dashboard
    	@merchant_store = current_merchant_store
    	@active_subscribers = @merchant_store.subscribers.active.count
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
  	end
end
