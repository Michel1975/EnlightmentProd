class Shared::MemberSessionsController < Shared::BaseController
  skip_before_filter :require_login, :only => [:new, :create]

  def create
    logger.info "Loading MemberSession create action"
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
    if user && user.sub_type == "Member"
      logger.debug "User logged in successfully: #{user.attributes.inspect}"
      store_session_variables(user)
      logger.debug "User session variables initialized. Loading root_url view for frontend"
      flash[:success] = t(:logged_in, :scope => [:business_validations, :session_member])
      redirect_back_or_to root_url
    else
      flash.now.alert = t(:invalid_login, :scope => [:business_validations, :session_member])
      render :new
    end
  end

	def destroy
    logger.info "Loading MemberSession destroy action"
  	logout
    delete_session_variables
    logger.debug "Member session deleted. Redirecting to root_url"
    flash[:success] = t(:logged_out, :scope => [:business_validations, :session_member])
  	redirect_to root_url
	end

end
