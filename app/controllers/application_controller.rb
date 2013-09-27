class ApplicationController < ActionController::Base
	protect_from_forgery
	require 'will_paginate/array'#https://github.com/mislav/will_paginate/issues/163
  
  include Shared::SessionsHelper
  
  def not_authenticated
  	redirect_to shared_login_url, :alert => "First login to access this page."
  end

  def determine_layout
    current_merchant_store.nil? ? "application" : "merchant"
  end
	
end
