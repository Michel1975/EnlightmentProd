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

  def admin_user
      redirect_to root_path unless current_user.sub_type == 'BackendAdmin'
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

  #Detailed logic for sign-up - used by several controllers
  #To-Do: For completed profiles or web profiles, we send e-mails instead of sms if signed up on web
  #If signed up in store, we always send sms to member - more logic and analysis is needed for this.
  def processSignup(member, subscriber, merchant_store, origin)
    if subscriber.nil?
      #Create new subscriber record
      merchant_store.subscribers.create(member_id: member.id, start_date: Time.zone.now)  
    else
      subscriber.signup
      subscriber.save!
    end

    if eligble_welcome_present?
      if origin == "store"
        #Send welcome message with notice about welcome present 
        SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success_with_present, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone )
      else
        #Send welcome e-mail with welcomepresent
        MemberMailer.web_sign_up_present(member, merchant_store).deliver
      end

      #Send welcome present if active for particular merchant - default is active.
      welcome_offer = merchant_store.welcome_offer
      if welcome_offer.active
        if origin == "store"
          SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( welcome_offer.description, member.phone )
        end
      end
    else
      if origin == "store"
        #Send normal welcome message without notes about welcome present
        SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success_without_present, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone ) 
      else
        #Send welcome e-mail without welcomepresent
        MemberMailer.web_sign_up(member, merchant_store).deliver
      end
    end
  end

  protected
    def current_users_list
      current_users.map {|u| u.username}.join(", ")
    end
	
end#end class
