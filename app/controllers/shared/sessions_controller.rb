class Shared::SessionsController < Shared::BaseController
	def create
  		user = login(params[:email], params[:password], params[:remember_me])
  		if user
        if user.sub_type == "MerchantUser"
          session[:current_merchant_store_id] = MerchantUser.find(user.sub_id).merchant_store.id
          store_session_variables(user)
        end
        
    		redirect_back_or_to merchant_dashboard_url, :notice => "Logged in!"
  		else
    		flash.now.alert = "Email or password was invalid"
    	render :new
  		end
	end

	def destroy
  		logout
      delete_session_variables
  		redirect_to root_url, :notice => "Logged out!"
	end
end # end controller class
