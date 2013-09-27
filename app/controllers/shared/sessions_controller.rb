class Shared::SessionsController < Shared::BaseController
	def create
  		user = login(params[:email], params[:password], params[:remember_me])
  		if user
        if user.sub_type == "MerchantUser"
          store_session_variables(user)
        end
    		redirect_back_or_to merchant_dashboard_url, :notice => "Logget ind!"
  		else
    		flash.now.alert = "Email eller password var ugyldigt"
    	render :new
  		end
	end

	def destroy
  		logout
      delete_session_variables
  		redirect_to root_url, :notice => "Logget ud!"
	end
end # end controller class
