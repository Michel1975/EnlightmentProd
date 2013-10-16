class Shared::MerchantSessionsController < Shared::BaseController
  skip_before_filter :require_login, :only => [:new, :create]
	
  def create
  		user = login(params[:email], params[:password], params[:remember_me])
  		#Login and verify user type to avoid invalid logins
      if user && user.sub_type == "MerchantUser"
        	store_session_variables(user)
        	if user.sub_type == 'MerchantUser'
          		name = MerchantUser.find(user.sub_id)
          		update_eventhistory("login", "Test")
          		redirect_back_or_to merchant_dashboard_url, :notice => t(:logged_in, :scope => [:business_validations, :session_merchant])
          else
            #to-do: skal smide en teknisk fejl eller tilpasset unautoirzed  - meget vigtigt hvis medlemmer forsøger at logge ind på butik eller admin
            render :new
          end
  		else
    		flash.now.alert = t(:invalid_login, :scope => [:business_validations, :session_merchant])
    	  render :new
  		end
	end

	def destroy
  		logout
      delete_session_variables
  		redirect_to root_url, :notice => t(:logged_out, :scope => [:business_validations, :session_merchant])
	end
end
