class Merchant::MerchantUsersController < Merchant::BaseController
	before_filter :require_login #man skal være merchantuser
	layout :determine_layout
	
	def show
		@merchant_user = current_merchant_user
	end

	def edit
		@merchant_user = current_merchant_user
	end

	def update
		@merchant_user = MerchantUser.find(params[:id])
    	if @merchant_user.update_attributes(params[:merchant_user])
      		flash[:success] = "Profil er opdateret"
      		redirect_to [:merchant, @merchant_user]
    	else
      		render 'edit'
    	end
	end	
end
