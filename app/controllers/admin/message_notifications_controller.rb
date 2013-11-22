class Admin::MessageNotificationsController < Admin::BaseController

	def index    
  		@message_notifications = MessageNotification.scoped.page( params[:page] ).per_page(15)
	end
end
