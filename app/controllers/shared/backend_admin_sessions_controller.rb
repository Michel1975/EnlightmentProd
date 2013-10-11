class Shared::BackendAdminSessionsController < Shared::BaseController
	skip_before_filter :require_login, :only => [:new, :create]
  
  	def create
  		user = login(params[:email], params[:password], params[:remember_me])
  		if user
        	store_session_variables(user)
          redirect_back_or_to admin_dashboard_url, :notice => t(:logged_in, :scope => [:business_validations, :session_admin])
  		else
    		flash.now.alert = t(:invalid_login, :scope => [:business_validations, :session_admin])
    	  render :new
  		end
	end

	def destroy
  	logout
    delete_session_variables
  	redirect_to root_url, :notice => t(:logged_out, :scope => [:business_validations, :session_admin])
	end
end
