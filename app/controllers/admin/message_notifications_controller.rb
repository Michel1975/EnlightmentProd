#encoding: utf-8
class Admin::MessageNotificationsController < Admin::BaseController

	#Test: OK
	def index    
		logger.info "Loading MessageNotifications index action"
  		@message_notifications = MessageNotification.scoped.page( params[:page] ).per_page(15)
  		logger.debug "MessageNotification attributes hash: #{@message_notifications.inspect}"
	end
end
