class Shared::MemberSessionsController < Shared::BaseController
  skip_before_filter :require_login, :only => [:new, :create]
  
  def create
  		user = login(params[:email], params[:password], params[:remember_me])
  		if user
        	store_session_variables(user)
          redirect_back_or_to root_url, :notice => "Logget ind som medlem!"
  		else
    		flash.now.alert = "Email eller password var ugyldigt"
    	  	render :new
  		end
	end

	def destroy
  	logout
    delete_session_variables
  	redirect_to root_url, :notice => "Logget ud som medlem!"
	end

end
