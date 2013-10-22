class Merchant::MerchantUsersController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
	
	def show
		@merchant_user = current_resource
	end

	def edit
		@merchant_user = current_resource
	end

	def update
		@merchant_user = current_resource
    	if @merchant_user.update_attributes(params[:merchant_user])
      		flash[:success] = t(:profile_updated, :scope => [:business_validations, :merchant_user])
      		redirect_to [:merchant, @merchant_user]
    	else
      		render 'edit'
    	end
	end

	private
  		def current_resource
    		@current_resource ||= MerchantUser.find(params[:id]) if params[:id]
  		end	
end
