class Shared::MemberSessionsController < Shared::BaseController
  skip_before_filter :require_login, :only => [:new, :create]
  
  def create
  		user = login(params[:email], params[:password], params[:remember_me])
  		#Login and verify user type to avoid invalid logins
      if user && user.sub_type == "Member"
        	store_session_variables(user)
          redirect_back_or_to root_url, :success => t(:logged_in, :scope => [:business_validations, :session_member])
  		else
    		flash.now.alert = t(:invalid_login, :scope => [:business_validations, :session_member])
    	  render :new
  		end
	end

	def destroy
  	logout
    delete_session_variables
  	redirect_to root_url, :success => t(:logged_out, :scope => [:business_validations, :session_member])
	end

end
