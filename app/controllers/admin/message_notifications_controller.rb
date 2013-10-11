class Admin::MessageNotificationsController < Admin::BaseController

	def index    
  		@message_notifications = MessageNotification.all
	end
end
