class Merchant::SubscribersController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
	
	def index
    	@subscribers = current_merchant_store.subscribers.paginate(page: params[:page])
	end

	def show
		@subscriber = Subscriber.find(params[:id])
	end

	def destroy
  		Subscriber.find(params[:id]).destroy
    	flash[:success] = t(:subscriber_removed, :scope => [:business_validations, :subscriber])
    	redirect_to merchant_subscribers_url
	end

	def prepare_single_message
		@subscriber = @subscriber = Subscriber.find(params[:id])
	end

	def send_single_message
		@subscriber = Subscriber.find(params[:id])
		message = params[:message]
		if SMSUtility::SMSFactory.validate_sms?(message)
			if SMSUtility::SMSFactory.sendSingleMessageInstant?(message, @subscriber.member.phone, current_merchant_store)
				flash[:success] = t(:success, :scope => [:business_validations, :instant_subscriber_message])
				redirect_to [:merchant, @subscriber]
			else
				flash.now[:error] = t(:error, :scope => [:business_validations, :instant_subscriber_message])
				render :prepare_single_message	
			end
		else
			flash.now[:error] = t(:invalid_message, :scope => [:business_validations, :instant_subscriber_message])
			render :prepare_single_message	
		end
	end


end
