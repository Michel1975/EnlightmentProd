class Admin::DashboardsController < Admin::BaseController

	def overview
		logger.info "Loading overview action"

		#Number of active stores
		@active_stores_count = MerchantStore.active.count
        logger.debug "Active stores count: #{@active_stores_count.inspect}"

		#Number of active members
    	@active_members_count = Member.active.count
        logger.debug "Active members count: #{@active_members_count.inspect}"

        #Number of active memberships (subscriptions)
    	@active_memberships_count = Subscriber.active.count
        logger.debug "Active memberships count: #{@active_memberships_count.inspect}"

        #Number of total sms-messages
        @total_sms_messages_count = MessageNotification.all.count
        logger.debug "Total sms messages count: #{@total_sms_messages_count.inspect}"

        #Number of total sms-messages sent this month
        @month_total_sms_messages_count = MessageNotification.month_total_messages.count
        logger.debug "Monthly total sms messages count: #{@month_total_sms_messages_count.inspect}"

        #Completed campaigns
        @completed_campaigns_count = Campaign.completed.count
        logger.debug "Completed campaigns count: #{@completed_campaigns_count.inspect}"

        #Active offers
        @active_offers_count = Offer.active.count
        logger.debug "Active offer count: #{@active_offers.inspect}"
        
        #Opt-outs total
        @opt_outs_total = Subscriber.inactive.count
        logger.debug "Opt-outs total: #{@opt_outs_total.inspect}"

        #Number of inactive members
    	@inactive_members_count = Member.inactive.count
        logger.debug "Inactive members count: #{@inactive_members_count.inspect}"
        
        #Chart data
        @new_member_data = Member.chart_data(14.day.ago)
        logger.debug "Recent member data: #{@new_member_data.inspect}"
        
        @recent_subscriber_data = Subscriber.chart_data(14.day.ago, nil, "day")
        logger.debug "Recent subscriber data: #{@recent_subscriber_data.inspect}"
        
        #To-Do: Skal ændres til group by month når postgress installeres på lokal maskine
        @months_subscriber_data = Subscriber.chart_data(16.weeks.ago, nil, "month")
        logger.debug "Monthly subscriber data: #{@months_subscriber_data.inspect}"
	end
end
