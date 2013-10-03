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
		flash[:success] = t(:subscriber_message_sent, :scope => [:business_validations, :subscriber])
		redirect_to [:merchant, @subscriber]
		#To-do: kald sms-handler m.v.
	end

end
