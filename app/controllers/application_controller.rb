#encoding: utf-8
class ApplicationController < ActionController::Base
	before_filter :require_login

  def default_url_options
    {:locale => I18n.locale}
  end

  require 'builder'  
  protect_from_forgery
	require 'will_paginate/array'#https://github.com/mislav/will_paginate/issues/163
  
  #include Shared::SessionsHelper
  include ApplicationHelper
  
  def merchant_user
      redirect_to root_path unless current_user.sub_type == 'MerchantUser'
  end

  def member_user
      redirect_to root_path unless current_user.sub_type == 'Member'
  end

  def not_authenticated
    redirect_to root_path, :alert => t(:not_authenticated, :scope => [:business_validations, :generic])
    #if current_user.sub_type == "MerchantUser"
  	   #redirect_to shared_login_merchant_url, :alert => "First login to access this page."
    #elsif current_user.sub_type == "Member"
       #redirect_to shared_login_member_url, :alert => "First login to access this page."  
    #end
  end

  helper_method :current_users_list
  #def determine_layout
    #current_merchant_store.nil? ? "application" : "merchant"
  #end

  def update_eventhistory(event_type, description)
    if(event_type && description)
      current_merchant_store.event_histories.create(event_type: event_type, description: description)
    end
  end

  protected
    def current_users_list
      current_users.map {|u| u.username}.join(", ")
    end

	
end#end class
