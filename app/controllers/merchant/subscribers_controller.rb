class Merchant::SubscribersController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
	
	def index
    	@subscribers = current_merchant_store.subscribers.where(active: true).paginate(page: params[:page])
	end

	def show
		@subscriber = current_resource
	end

	def destroy
  		subscriber = current_resource
		subscriber.opt_out
		if subscriber.save!
			flash[:success] = t(:subscriber_removed, :scope => [:business_validations, :subscriber])
    		redirect_to merchant_subscribers_url
		else
			flash[:error] = t(:subscriber_remove_error, :scope => [:business_validations, :subscriber])
    		redirect_to merchant_subscribers_url
		end
	end

	def prepare_single_message
		@subscriber = current_resource
	end

	def send_single_message
		@subscriber = current_resource
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

	private
  		def current_resource
    		@current_resource ||= Subscriber.find(params[:id]) if params[:id]
  		end

end
