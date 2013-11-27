class Shared::MerchantSessionsController < Shared::BaseController
  skip_before_filter :require_login, :only => [:new, :create]
	
  def create
    logger.info "Loading MerchantSession create action"
  		user = login(params[:email], params[:password], params[:remember_me])
  		#Login and verify user type to avoid invalid logins
      if user && user.sub_type == "MerchantUser"
        logger.debug "Merchant logged in successfully: #{user.attributes.inspect}"
        	store_session_variables(user)
          logger.debug "User session variables initialized. Loading root_url view for frontend"
        	if user.sub_type == 'MerchantUser'
              m_user = MerchantUser.find(current_user.sub_id)
              log_event_history_merchant_portal(current_merchant_store, "login", "#{m_user.name} loggede ind.")
          		redirect_back_or_to merchant_dashboard_url, :success => t(:logged_in, :scope => [:business_validations, :session_merchant])
          else
            #to-do: skal smide en teknisk fejl eller tilpasset unautoirzed  - meget vigtigt hvis medlemmer forsøger at logge ind på butik eller admin
            render :new
          end
  		else
        logger.debug "Invalid login. Loading new view with errors"
    		flash.now.alert = t(:invalid_login, :scope => [:business_validations, :session_merchant])
    	  render :new
  		end
	end

	def destroy
    logger.info "Loading MerchantSession destroy action"
    m_user = MerchantUser.find(current_user.sub_id)
    log_event_history_merchant_portal(current_merchant_store, "logout", "#{m_user.name} loggede ud.")
  	logout
    delete_session_variables
    logger.debug "Merchant session deleted. Redirecting to root_url"
    flash[:success] = t(:logged_out, :scope => [:business_validations, :session_merchant])
  	redirect_to root_url
	end
end
