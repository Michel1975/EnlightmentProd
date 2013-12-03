#encoding: utf-8
class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers
	before_filter :require_login, :except => [:processSignup]
  before_filter :authorize, :except => [:processSignup]

  #Security measures
  delegate :allow?, to: :current_permission
  helper_method :allow?

  def default_url_options
    {:locale => I18n.locale}
  end

  require 'builder'  
  protect_from_forgery
	require 'will_paginate/array'#https://github.com/mislav/will_paginate/issues/163
  
  #include Shared::SessionsHelper
  include ApplicationHelper
  
  def merchant_user
    logger.info "Checking if user type is MerchantUser..."
    logger.debug "User type: #{current_user.sub_type.inspect}"
    redirect_to root_path unless current_user.sub_type == 'MerchantUser'
  end

  def member_user
    logger.info "Checking if user type is Member..."
    logger.debug "User type: #{current_user.sub_type.inspect}"
    redirect_to root_path unless current_user.sub_type == 'Member'
  end

  def admin_user
    logger.info "Checking if user type is AdminUser..."
    logger.debug "User type: #{current_user.sub_type.inspect}"
    redirect_to root_path unless current_user.sub_type == 'BackendAdmin'
  end

  def not_authenticated
    logger.info "User not authenticated. Redirecting to root_path..."
    redirect_to root_path, :alert => t(:not_authenticated, :scope => [:business_validations, :generic])
  end

  helper_method :current_users_list
  #def determine_layout
    #current_merchant_store.nil? ? "application" : "merchant"
  #end

  def log_event_history_merchant_portal(merchant_store, event_type, description)
    logger.info "Updating event-history for store"
    if merchant_store && event_type && description
      logger.debug "Event-history for store: #{merchant_store.store_name.inspect}, event_type: #{event_type.inspect}, description: #{description.inspect}"
      merchant_store.event_histories.create(event_type: event_type, description: description)
      logger.debug "Event history updated for specific store"
    else
      logger.fatal "Could not log events correctly. Missing attributes"
      logger.debug "Could not log events correctly. Missing attributes"
    end
  end
  
=begin moved to smsutility for better usage in worker threads
  #Detailed logic for sign-up - used by several controllers
  #To-Do: For completed profiles or web profiles, we send e-mails instead of sms if signed up on web
  #If signed up in store, we always send sms to member - more logic and analysis is needed for this.
  def processSignup(member, merchant_store, origin)
    logger.info "Loading processSignup method"
    logger.debug "Member parameter: #{member.attributes.inspect}" if member.present?
    logger.debug "Merchant-store parameter: #{merchant_store.attributes.inspect}" if merchant_store.present?
    logger.debug "Origin parameter: #{origin.inspect}" 
    
    sign_up_status = false
    #Check if subscriber record already exists for specific merchant_store
    subscriber = merchant_store.subscribers.find_by_member_id(member.id)
    if subscriber.nil?
      #Create new subscriber record
      if subscriber = merchant_store.subscribers.create(member_id: member.id, start_date: Time.zone.now) 
        logger.debug "Subscriber does not exist. New subscriber created: #{subscriber.attributes.inspect}"
        sign_up_status = true 
      end
    elsif subscriber && origin == "store"
       #We only send sms for incorrect signups in stores - not on web since validation message is shown directly in interface
      result = SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:already_signed_up, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone, merchant_store )
      logger.debug "Notification message sent successfully in SMS Gateway" if result 
    end

    if sign_up_status
      logger.debug "Proceeding to next step: Send welcome message (email, sms) to member if eligble"
      if subscriber.eligble_welcome_present? 
        logger.debug "Subscriber is eligble for welcome present"
        if origin == "store"
          logger.debug "Subscriber origin: #{origin.inspect}"
          logger.debug "Sending SMS welcome message with notice about present to member"
          #Send welcome message with notice about welcome present 
          result = SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success_with_present, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone, merchant_store )
          logger.debug "Welcome message sent successfully in SMS Gateway" if result
        else
          logger.debug "Subscriber origin: #{origin.inspect}"
          logger.debug "Sending one e-mail with welcome message and present to member"
          #Send welcome e-mail with welcomepresent
          MemberMailer.delay.web_sign_up_present(member.id, merchant_store.id)
        end

        #Send welcome present if active for particular merchant - default is active.
        welcome_offer = merchant_store.welcome_offer
        if welcome_offer.active
          logger.debug "Welcome offer is active for merchant-store"
          if origin == "store"
            logger.debug "Subscriber origin: #{origin.inspect}"
            logger.debug "Sending SMS message with welcome present"
            result = SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( welcome_offer.message, member.phone, merchant_store )
            logger.debug "Welcome present sent successfully in SMS Gateway" if result
          end
        end
      else
        logger.debug "Subscriber NOT eligble for welcome present"
        if origin == "store"
          logger.debug "Subscriber origin: #{origin.inspect}"
          logger.debug "Sending SMS message with welcome message without present"
          #Send normal welcome message without notes about welcome present
          result = SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success_without_present, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone, merchant_store )
          logger.debug "Welcome message sent successfully in SMS Gateway" if result 
        else
          logger.debug "Subscriber origin: #{origin.inspect}"
          logger.debug "Sending email with welcome message but no present"
          #Send welcome e-mail without welcomepresent
          MemberMailer.delay.web_sign_up(member.id, merchant_store.id)
        end
      end
    end
  end
=end

  #Permission methods
  def current_permission
    @current_permission ||= Permissions.permission_for(current_user, current_merchant_store)
  end

  def current_resource
    nil
  end

  #Ensures admin login can only happen from authorized ips
  def admin_constraint
    if Rails.env.production?
      @ips = [ ENV["ADMIN_IP1"], ENV["ADMIN_IP2"] ] 
      if not @ips.include? request.remote_ip
        flash[:alert] = t(:not_authorized, :scope => [:business_messages, :security])
        redirect_to root_url
      end
    end
  end

  def authorize
    logger.debug "Into authorize method..."
    #Log authorize
    logger.debug("Controller param:" + params[:controller] + ", Action param: " + params[:action])
    if !current_permission.allow?(self.controller_name, params[:action], current_resource)
      if current_user.nil? || current_user.sub_type == "Member"
        redirect_to root_url, alert: t(:not_authorized, :scope => [:business_messages, :security])
      elsif current_user && current_user.sub_type == "MerchantUser"
        redirect_to merchant_dashboard_url, alert: t(:not_authorized, :scope => [:business_messages, :security])
      elsif current_user && current_user.sub_type == "BackendAdmin"
        redirect_to admin_dashboard_url, t(:not_authorized, :scope => [:business_messages, :security])
      end
    end
  end

  #protected
    #def current_users_list
      #current_users.map {|u| u.username}.join(", ")
    #end
	
end#end class
