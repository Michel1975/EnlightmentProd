class Shared::MerchantSessionsController < Shared::BaseController
  skip_before_filter :require_login, :only => [:new, :create]
	def create
  		user = login(params[:email], params[:password], params[:remember_me])
  		if user
        	store_session_variables(user)
        	if user.sub_type == 'MerchantUser'
          		name = MerchantUser.find(user.sub_id)
          		update_eventhistory("login", "Test")
          		redirect_back_or_to merchant_dashboard_url, :notice => "Logget ind som butik!"
        	end
  		else
    		flash.now.alert = "Email eller password var ugyldigt"
    	  	render :new
  		end
	end

	def destroy
  		logout
      	delete_session_variables
  		redirect_to root_url, :notice => "Logget ud som butik!"
	end
end
