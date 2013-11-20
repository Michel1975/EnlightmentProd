class Admin::DashboardsController < Admin::BaseController

	def overview
		logger.info "Loading overview action"

		#Number of active stores
		@active_stores_count = MerchantStore.active.count
        logger.debug "Active stores count: #{@active_stores_count.inspect}"

		#Total number of members
    	@total_members_count = Member.all.count
        logger.debug "Total members count: #{@total_members_count.inspect}"

        #Number of total memberships (subscriptions)
    	@total_memberships_count = Subscriber.all.count
        logger.debug "Total memberships count: #{@total_memberships_count.inspect}"

        #Number of send total sms-messages
        @total_sms_messages_count = MessageNotification.all.count
        logger.debug "Total sent sms messages count: #{@total_sms_messages_count.inspect}"

        #Number of total sms-messages sent this month
        @month_total_sms_messages_count = MessageNotification.month_total_messages.count
        logger.debug "Monthly total sms messages count: #{@month_total_sms_messages_count.inspect}"

        #Completed campaigns
        @completed_campaigns_count = Campaign.completed.count
        logger.debug "Completed campaigns count: #{@completed_campaigns_count.inspect}"

        #Active offers
        @active_offers_count = Offer.active.count
        logger.debug "Active offer count: #{@active_offers.inspect}"
        
        #Sign-outs total
        @sign_outs_total = SubscriberHistory.sign_outs.count
        logger.debug "Sign_outs total: #{@sign_outs_total.inspect}"

        #Sign-ups total
        @sign_ups_total = SubscriberHistory.sign_ups.count
        logger.debug "Sign_ups total: #{@sign_ups_total.inspect}"
        
        #Chart data
        @new_member_data = Member.chart_data(14.day.ago)
        logger.debug "Recent member data: #{@new_member_data.inspect}"
        
        @recent_subscriber_data = SubscriberHistory.chart_data(14.day.ago, nil, "day")
        logger.debug "Recent subscriber data: #{@recent_subscriber_data.inspect}"
        
        #To-Do: Skal ændres til group by month når postgress installeres på lokal maskine
        @months_subscriber_data = SubscriberHistory.chart_data(16.weeks.ago, nil, "month")
        logger.debug "Monthly subscriber data: #{@months_subscriber_data.inspect}"
	end
end
