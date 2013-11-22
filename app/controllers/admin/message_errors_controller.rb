class Admin::MessageErrorsController < Admin::BaseController
  def index    
  		@message_errors = MessageError.scoped.page( params[:page] ).per_page(15)
	end
end
