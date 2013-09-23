class ApplicationController < ActionController::Base
  protect_from_forgery
  include Shared::SessionsHelper
	
	def not_authenticated
  		redirect_to shared_login_url, :alert => "First login to access this page."
	end
	
end
