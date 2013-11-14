class Shared::MemberSessionsController < Shared::BaseController
  skip_before_filter :require_login, :only => [:new, :create]
  
  def create
    logger.info "Loading MemberSession create action"
  		user = login(params[:email], params[:password], params[:remember_me])
  		#Login and verify user type to avoid invalid logins
      if user && user.sub_type == "Member"
        logger.debug "Member logged in successfully: #{user.attributes.inspect}"
        	store_session_variables(user)
          logger.debug "User session variables initialized. Loading root_url view for frontend"
          redirect_back_or_to root_url, :success => t(:logged_in, :scope => [:business_validations, :session_member])
  		else
        logger.debug "Invalid login. Loading new view with errors"
    		flash.now.alert = t(:invalid_login, :scope => [:business_validations, :session_member])
    	  render :new
  		end
	end

	def destroy
    logger.info "Loading MemberSession destroy action"
  	logout
    delete_session_variables
    logger.debug "Member session deleted. Redirecting to root_url"
  	redirect_to root_url, :success => t(:logged_out, :scope => [:business_validations, :session_member])
	end

end
