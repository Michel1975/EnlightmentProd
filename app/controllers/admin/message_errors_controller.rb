#encoding: utf-8
class Admin::MessageErrorsController < Admin::BaseController
  #Test: OK
  def index 
  	logger.info "Loading MerchantError index action"   
  	@message_errors = MessageError.scoped.page( params[:page] ).per_page(15)
  	logger.debug "Message Error attributes hash: #{@message_errors.inspect}"
  end
end
