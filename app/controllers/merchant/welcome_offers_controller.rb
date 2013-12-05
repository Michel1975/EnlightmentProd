class Merchant::WelcomeOffersController < Merchant::BaseController
	
	#Test:OK
	def show
		logger.info "Loading welcome_offer show action"
    	@welcome_offer = current_resource #Old:current_merchant_store.welcome_offer
    	logger.debug "Welcome offer - attributes hash: #{@welcome_offer.attributes.inspect}"
	end

	#Test:OK
	def edit
		logger.info "Loading welcome_offer edit action"
		@welcome_offer = current_resource
		logger.debug "Welcome offer - attributes hash: #{@welcome_offer.attributes.inspect}"
		#Used for max-length property in textarea
		@message_limit = 160 - current_merchant_store.store_regards.length
		logger.debug "Message limit: #{@message_limit.inspect}"
	end

	#Test:OK
	def update
		logger.info "Loading welcome_offer update action"
		@welcome_offer = current_resource
		logger.debug "Welcome offer - attributes hash: #{@welcome_offer.attributes.inspect}"

		#Used for max-length property in textarea
		@message_limit = 160 - current_merchant_store.store_regards.length
		logger.debug "Message limit: #{@message_limit.inspect}"

    	respond_to do |format|
      		if @welcome_offer.update_attributes(params[:welcome_offer])
      			logger.debug "Welcome offer updated successfully: #{@welcome_offer.attributes.inspect}"
        		format.html { redirect_to [:merchant, @welcome_offer], :success => t(:offer_updated, :scope => [:business_validations, :welcome_offer]) }
      		else
      			logger.debug "Validation errors. Loading edit view with errors"
        		format.html { render action: "edit" }
      		end
      	end
	end

	private
  		def current_resource
    		@current_resource ||= WelcomeOffer.find(params[:id]) if params[:id]
  		end

end
