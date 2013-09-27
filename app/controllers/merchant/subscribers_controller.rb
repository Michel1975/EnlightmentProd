class Merchant::SubscribersController < Merchant::BaseController
	before_filter :require_login #man skal være merchantuser
	layout :determine_layout

	def index
    	@subscribers = current_merchant_store.subscribers.paginate(page: params[:page])
	end

	def show
		@subscriber = Subscriber.find(params[:id])
	end

	def destroy
  		Subscriber.find(params[:id]).destroy
    	flash[:success] = "Medlem er fjernet fra kundeklubben."
    	redirect_to merchant_subscribers_url
	end

	def prepare_single_message
		@subscriber = @subscriber = Subscriber.find(params[:id])
	end

	def send_single_message
		@subscriber = Subscriber.find(params[:id])
		message = params[:message]
		flash[:success] = "Besked er afsendt"
		redirect_to [:merchant, @subscriber]
		#To-do: kald sms-handler m.v.
	end

end
