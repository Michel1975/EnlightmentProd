class Shared::BackendAdminSessionsController < Shared::BaseController
	skip_before_filter :require_login, :only => [:new, :create]
  
  	def create
      logger.info "Loading BackendAdminSession create action"
  		user = login(params[:email], params[:password], params[:remember_me])
  		#Login and verify user type to avoid invalid logins
      if user && user.sub_type == "BackendAdmin"
          logger.debug "Backend user logged in successfully: #{user.attributes.inspect}"
        	store_session_variables(user)
          logger.debug "User session variables initialized. Loading dashboard view for backend"
          redirect_back_or_to admin_dashboard_url, :notice => t(:logged_in, :scope => [:business_validations, :session_admin])
  		else
        logger.debug "Invalid login. Loading new view with errors"
    		flash.now.alert = t(:invalid_login, :scope => [:business_validations, :session_admin])
    	  render :new
  		end
	end

	def destroy
    logger.info "Loading BackendAdminSession destroy action"
  	logout
    delete_session_variables
    logger.debug "Backend user session deleted. Redirecting to root_url"
  	redirect_to root_url, :notice => t(:logged_out, :scope => [:business_validations, :session_admin])
	end
end
