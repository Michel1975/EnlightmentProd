class Merchant::MerchantUsersController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
	
	def show
		@merchant_user = current_merchant_user
	end

	def edit
		@merchant_user = current_merchant_user
	end

	def update
		@merchant_user = MerchantUser.find(params[:id])
    	if @merchant_user.update_attributes(params[:merchant_user])
      		flash[:success] = t(:profile_updated, :scope => [:business_validations, :merchant_user])
      		redirect_to [:merchant, @merchant_user]
    	else
      		render 'edit'
    	end
	end	
end
