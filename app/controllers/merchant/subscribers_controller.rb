class Merchant::SubscribersController < Merchant::BaseController
	#Test:OK
	def index
		logger.info "Loading subscriber index action"
    	@subscribers = current_merchant_store.subscribers.page(params[:page]).per_page(10)
    	logger.debug "Subscribers - attributes hash: #{@subscribers.inspect}"
	end

	#Test:OK
	def show
		logger.info "Loading subscriber show action"
		@subscriber = current_resource
		logger.debug "Subscriber - attributes hash: #{@subscriber.attributes.inspect}"
	end

	#Test:OK
	def destroy
		logger.info "Loading subscriber destroy action"
  		subscriber = current_resource
  		logger.debug "Subscriber - attributes hash: #{subscriber.attributes.inspect}"
		if subscriber.destroy
			logger.debug "Subscriber deleted successfully"
			flash[:success] = t(:subscriber_removed, :scope => [:business_validations, :subscriber])
    		redirect_to merchant_subscribers_url
		else
			logger.debug "Error when updating subscriber status. Redirecting to subscribers list"
			flash[:error] = t(:subscriber_remove_error, :scope => [:business_validations, :subscriber])
    		redirect_to merchant_subscribers_url
		end
	end

	#Test:OK
	def prepare_single_message
		logger.info "Loading subscriber prepare_single_message action"
		@subscriber = current_resource
		logger.debug "Subscriber - attributes hash: #{@subscriber.attributes.inspect}"
		@stop_link = @subscriber.opt_out_link_sms
		logger.debug "Stop link: #{@stop_link.inspect}"
		@message_limit = 160 - @subscriber.opt_out_link_sms.length
    	logger.debug "Message limit: #{@message_limit.inspect}"
	end

	#Test:OK
	def send_single_message
		logger.info "Loading Subscribers send_single_message action"
		@subscriber = current_resource
		logger.debug "Subscriber - attributes hash: #{@subscriber.attributes.inspect}"
		
		@gateway_status = ENV['SMS_GATEWAY_ACTIVE']
    	logger.debug "SMS Gateway flag: #{@gateway_status}"
    	
    	if @gateway_status == "true"
    		logger.debug "Gateway status is active...proceeding"
			
			message = params[:message]
			logger.debug "Message without opt-out link: #{message.inspect}"
			message = message + @subscriber.opt_out_link_sms
			logger.debug "Message with opt_out link: #{message.inspect}"
			no_characters = message.length
			logger.debug "Message character length: #{no_characters.inspect}"

			logger.debug "Validating monthly message limits..."
	      	#Validate monthly message limits
      		if current_merchant_store.validate_monthly_message_limit?(1)
      			logger.debug "Monthly message limit not broken for store...proceeding"
				if SMSUtility::SMSFactory.validate_sms?(message) && no_characters < 160
					logger.debug "Message validation OK"
					if SMSUtility::SMSFactory.sendSingleMessageInstant?(message, @subscriber.member.phone, current_merchant_store)
						logger.debug "Message confirmed OK in SMS gateway"
						flash[:success] = t(:success, :scope => [:business_validations, :instant_subscriber_message])
						redirect_to merchant_subscribers_path#[:merchant, @subscriber]
					else
						logger.debug "Error: Message NOT confirmed in SMS gateway"
						logger.fatal "Error: Message NOT confirmed in SMS gateway"
						flash.now[:error] = t(:error, :scope => [:business_validations, :instant_subscriber_message])
						render :prepare_single_message	
					end
				else
					logger.debug "Message validation ERROR - invalid characters or message too long"
					flash.now[:error] = t(:invalid_message, :scope => [:business_validations, :instant_subscriber_message])
					render :prepare_single_message	
				end
			else
				logger.debug "Monthly message limit is broken. Cannot create campaign"
        		flash[:error] = t(:monthly_message_limit_broken, total_messages: SMSUtility::STORE_TOTAL_MESSAGES_MONTH, :scope => [:system])
        		redirect_to merchant_subscribers_path
			end
		else
			logger.debug "SMS Gateway is set to inactive - thus new campaigns cannot be created"
      		flash[:error] = t(:gateway_inactive_single, :scope => [:system])
      		redirect_to merchant_subscribers_path
		end
	end

	private
  		def current_resource
    		@current_resource ||= Subscriber.find(params[:id]) if params[:id]
  		end

end
