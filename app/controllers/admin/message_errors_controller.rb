class Admin::MessageErrorsController < Admin::BaseController
  def index    
  		@message_errors = MessageError.all.paginate(page: params[:page])
	end
end
