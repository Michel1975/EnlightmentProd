class Admin::MessageNotificationsController < Admin::BaseController

	def index    
  		@message_notifications = MessageNotification.all.paginate(page: params[:page])
	end
end
