class Merchant::WelcomeOffersController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
	
	def show
    	@welcome_offer = current_resource #Old:current_merchant_store.welcome_offer
	end

	def edit
		@welcome_offer = current_resource
	end

	def update
		@welcome_offer = current_resource

    	respond_to do |format|
      		if @welcome_offer.update_attributes(params[:welcome_offer])
        		format.html { redirect_to [:merchant, @welcome_offer], notice: t(:offer_updated, :scope => [:business_validations, :welcome_offer]) }
      		else
        		format.html { render action: "edit" }
      		end
      	end
	end

	private
  		def current_resource
    		@current_resource ||= WelcomeOffer.find(params[:id]) if params[:id]
  		end

end
