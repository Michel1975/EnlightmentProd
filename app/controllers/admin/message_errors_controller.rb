class Admin::MessageErrorsController < ApplicationController
  def index    
  		@message_errors = MessageError.all.paginate(page: params[:page])
	end
end
