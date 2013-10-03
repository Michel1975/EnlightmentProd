class Merchant::WelcomeOffersController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
	
	def show
    	@welcome_offer = current_merchant_store.welcome_offer
	end

	def edit
		@welcome_offer = WelcomeOffer.find(params[:id])
	end

	def update
		@welcome_offer = WelcomeOffer.find(params[:id])

    	respond_to do |format|
      		if @welcome_offer.update_attributes(params[:welcome_offer])
        		format.html { redirect_to [:merchant, @welcome_offer], notice: t(:offer_updated, :scope => [:business_validations, :welcome_offer]) }
      		else
        		format.html { render action: "edit" }
      		end
      	end
	end

end
