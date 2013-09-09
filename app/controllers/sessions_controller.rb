class SessionsController < ApplicationController
	def create
  		user = login(params[:email], params[:password], params[:remember_me])
  		if user
        store_session_variables(user)
    		redirect_back_or_to dashboard_url, :notice => "Logged in!"
  		else
    		flash.now.alert = "Email or password was invalid"
    	render :new
  		end
	end

	def destroy
  		logout
      delete_session_variables
  		redirect_to root_url, :notice => "Logged out!"
	end
end # end controller class
