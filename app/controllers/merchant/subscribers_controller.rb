class Merchant::SubscribersController < Merchant::BaseController
	def index
		logger.info "Loading subscriber index action"
    	@subscribers = current_merchant_store.subscribers.where(active: true).page(params[:page]).per_page(10)
    	logger.debug "Subscribers - attributes hash: #{@subscribers.inspect}"
	end

	def show
		logger.info "Loading subscriber show action"
		@subscriber = current_resource
		logger.debug "Subscriber - attributes hash: #{@subscriber.attributes.inspect}"
	end

	def destroy
		logger.info "Loading subscriber destroy action"
  		subscriber = current_resource
  		logger.debug "Subscriber - attributes hash: #{subscriber.attributes.inspect}"
		subscriber.opt_out
		if subscriber.save!
			logger.debug "Subscriber status changed successfully to inactive - attributes hash: #{subscriber.attributes.inspect}"
			flash[:success] = t(:subscriber_removed, :scope => [:business_validations, :subscriber])
    		redirect_to merchant_subscribers_url
		else
			logger.debug "Error when updating subscriber status. Redirecting to subscribers list"
			flash[:error] = t(:subscriber_remove_error, :scope => [:business_validations, :subscriber])
    		redirect_to merchant_subscribers_url
		end
	end

	def prepare_single_message
		logger.info "Loading subscriber prepare_single_message action"
		@subscriber = current_resource
		logger.debug "Subscriber - attributes hash: #{@subscriber.attributes.inspect}"
		@message_limit = 160 - 30 #Safe guess on bitly length.
    	logger.debug "Message limit: #{@message_limit.inspect}"

    	#SMS stop link - if we decide to go with this option
    	@stop_link = "\nStop: STOP #{current_merchant_store.sms_keyword} til 1276 222"
    	logger.debug "Stop link: #{@stop_link.inspect}"
		#Used for max-length property in textarea
		#old: @message_limit = 160 - @subscriber.opt_out_link.length

	end

	def send_single_message
		logger.info "Loading subscriber send_single_message action"
		@subscriber = current_resource
		logger.debug "Subscriber - attributes hash: #{@subscriber.attributes.inspect}"
		message = params[:message]
		logger.debug "Message without opt-out link: #{message.inspect}"
		message = message + @subscriber.opt_out_link_sms
		logger.debug "Message with opt_out link: #{message.inspect}"
		no_characters = message.length
		logger.debug "Message character length: #{no_characters.inspect}"

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
	end

	private
  		def current_resource
    		@current_resource ||= Subscriber.find(params[:id]) if params[:id]
  		end

end
