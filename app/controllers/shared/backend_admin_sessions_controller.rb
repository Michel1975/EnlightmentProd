class Shared::BackendAdminSessionsController < Shared::BaseController
	skip_before_filter :require_login, :only => [:new, :create]
  before_filter :admin_constraint
  
	def create
    logger.info "Loading BackendAdminSession create action"
    #Remove old session data to be sure
    logout
    delete_session_variables
    #Remove whitespace
    email = params[:email]
    email.strip if email
    password = params[:password]
    password.strip if password

		user = login(email, password, params[:remember_me])
		#Login and verify user type to avoid invalid logins
    if user && user.sub_type == "BackendAdmin"
        logger.debug "Backend user logged in successfully: #{user.attributes.inspect}"
      	store_session_variables(user)
        logger.debug "User session variables initialized. Loading dashboard view for backend"
        flash[:success] = t(:logged_in, :scope => [:business_validations, :session_admin])
        redirect_back_or_to admin_dashboard_url
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
    flash[:success] = t(:logged_out, :scope => [:business_validations, :session_admin])
  	redirect_to root_url
	end
end
