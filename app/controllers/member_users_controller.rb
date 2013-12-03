class MemberUsersController < ApplicationController
  #Default layout application is used
	skip_before_filter :require_login, :only => [:new, :create, :complete_sms_profile, :update_sms_profile, :terms_conditions, :confirm_email]
  skip_before_filter :authorize, :only => [:new, :create, :complete_sms_profile, :update_sms_profile, :terms_conditions, :confirm_email]
  before_filter :member_user,  :only => [:edit, :update, :show, :destroy, :favorites]
  
  #Vigtig! http://apidock.com/rails/ActionView/Helpers/FormHelper/fields_for
  
  #Create new member frontend - invoked from email link
  #Test:OK
  def confirm_email
    logger.info "Loading MemberUser confirm_email action" 
    token = params[:token]
    logger.debug "Token - param: #{token.inspect}"
    email = params[:email]
    logger.debug "Email - param: #{email.inspect}"
    member = Member.find_by_access_key(token)
    logger.debug "Member found from token - attributes hash: #{member.attributes.inspect}"
    @confirmed_status = false
    if member && member.user.try(:email) == email
      member.email_confirmed = true
      if member.save
        @confirmed_status = true
      end
    else
      logger.debug "Error: Invalid request attributes when confirming email"
      flash[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
      redirect_to root_path
    end
  end

  #Test:OK
  def resend_email_confirmation
    logger.info "Loading MemberUser resend_email_confirmation action"
    @member_user = current_resource
    logger.debug "Member found - attributes hash: #{@member_user.attributes.inspect}"
    #Only send if email is not confirmed
    if !@member_user.email_confirmed
      logger.debug "Email is not confirmed - sending new activation link"
      MemberMailer.delay.email_confirmation_link(@member_user.id)
      flash[:success] = t(:email_confirmation_sent, :scope => [:business_validations, :frontend, :member_user])
      redirect_to member_user_path(@member_user)
    else
      logger.debug "Email already confirmed. Reloading view with notification"
      flash[:alert] = t(:email_confirmation_error, :scope => [:business_validations, :frontend, :member_user])
      redirect_to member_user_path(@member_user)
    end
  end

  #Test:OK
  def send_mobile_confirmation_with_sms 
    logger.info "Loading MemberUser send_mobile_confirmation_with_sms action"
    @member_user = current_resource
    logger.debug "Member found - attributes hash: #{@member_user.attributes.inspect}"
    message = t(:sms_code_message, sms_code: @member_user.phone_confirmation_code, :scope => [:business_messages, :web_profile])
    logger.debug "SMS message to be sent: #{message.inspect}"
    if SMSUtility::SMSFactory.sendSingleAdminMessageInstant?(message, @member_user.phone, nil )
      logger.debug "SMS message sent successfully to #{@member_user.phone}"
      flash[:success] = t(:sms_confirmation_sent, phone_number: @member_user.phone, :scope => [:business_validations, :frontend, :member_user])
      redirect_to member_user_path(@member_user)
    else
      logger.debug "Error when sending sms to member phone"
      logger.fatal "Error when sending sms to member phone"
      flash[:alert] = t(:sms_confirmation_error, :scope => [:business_validations, :frontend, :member_user])
      redirect_to member_user_path(@member_user)
    end
  end

  #Test:OK
  def confirm_mobile_sms_code 
    logger.info "Loading MemberUser confirm_mobile_sms_code action"
    @member_user = current_resource
    logger.debug "Member found - attributes hash: #{@member_user.attributes.inspect}"
    sms_code = params[:sms_code]
    logger.debug "SMS-code - param: #{sms_code.inspect}"
    @confirmed_status = false
    if @member_user && @member_user.phone_confirmation_code.to_s == sms_code
      logger.debug "Match between codes..proceeding with save"
      @member_user.phone_confirmed = true
      if @member_user.save
        @confirmed_status = true
      end
    end

    if @confirmed_status
      logger.debug "SMS-code match..phone number is now confirmed"
      flash[:success] = t(:phone_confirmed_success, :scope => [:business_validations, :frontend, :member_user])
      redirect_to member_user_path(@member_user)
    else
      logger.debug "Phone not confirmed due to invalid sms-code or technical error"
      logger.fatal "Phone not confirmed due to invalid sms-code or technical error"
      flash[:alert] = t(:phone_confirmed_error, :scope => [:business_validations, :frontend, :member_user])
      redirect_to member_user_path(@member_user)
    end
  end

  #Test:OK
	def new
    logger.info "Loading MemberUser new action"
		#Fik en fejl på date_select efter vi skiftede til dansk locale
		#Læs denne artikel: http://i18n.lighthouseapp.com/projects/14947/tickets/12-i18n-and-date_select-exception
  	logger.debug "Building new member object with user association"
    @member_user = Member.new
  	@member_user.build_user()
	end

  #Create new member frontend
  #Test:OK
  def create 
    logger.info "Loading MemberUser create action"  
    @member_user = Member.new(params[:member])
    logger.debug "New member form values - attributes hash: #{@member_user.attributes.inspect}"
    @member_user.origin = 'web'
    logger.debug "Origin set to -> #{@member_user.origin.inspect}"
    @member_user.validation_mode = "web"
    logger.debug "Web validation mode set - #{@member_user.validation_mode.inspect}"
    if @member_user.valid_with_captcha?
      logger.debug "Member form values incl captcha valid...proceeding"
      if @member_user.save
        logger.debug "New member saved successfully..."
        #Send welcome e-mail for web profiles
        logger.debug "Sending delayed welcome email to new member"
        MemberMailer.delay.welcome_mail_new_member(@member_user.id)
        flash[:success] = t(:member_created, :scope => [:business_validations, :frontend, :member_user])
        redirect_to root_path
      else
        logger.debug "Error when creating member"
        logger.fatal "Error when creating member"
        flash[:error] = t(:member_create_error, :scope => [:business_validations, :frontend, :member_user])
        redirect_to root_path
      end
    else
      logger.debug "Member form values not valid. Loading new view with validation errors"
      render :new
    end
  end

  #Test:OK
  def edit
    logger.info "Loading MemberUser edit action"
  	#logger.info("Michel:" + current_member_user.id + "current_user-id:" + current_user.id)
  	@member_user = current_resource #Old:current_member_user
    logger.debug "Member attributes hash: #{@member_user.attributes.inspect}"
    @member_user.validation_mode = "web"
    logger.debug "Web validation mode set to -> #{@member_user.validation_mode.inspect}"
  end

  #Test:OK
  def terms_conditions
    logger.info "Loading MemberUser terms_conditions action"
  end

  #Test:OK
  def show
    logger.info "Loading MemberUser show action"
  	@member_user = current_resource #Old:current_member_user
    logger.debug "Member attributes hash: #{@member_user.attributes.inspect}"	
  end

  #Test:OK
  def update
    logger.info "Loading MemberUser update action"
  	@member_user = current_resource
    logger.debug "Member attributes hash: #{@member_user.attributes.inspect}"
    @member_user.validation_mode = "web"
    logger.debug "Web validation mode set to -> #{@member_user.validation_mode.inspect}"
    email_old = @member_user.user.try(:email)
    phone_old = @member_user.phone

    if @member_user.update_attributes(params[:member])
      logger.debug "Member updated succesfully - attributes hash: #{@member_user.attributes.inspect}" 
      logger.debug "Proceeding to check if email or phone has changed...if so, confirmation status must be properly updated"
      #Check if email or phone has changed
      changed = false
      if @member_user.email_confirmed && email_old != @member_user.user.email
        logger.debug "Email has changed: Old -> #{email_old.inspect}: New -> #{@member_user.user.email.inspect}"
        changed = true
        @member_user.email_confirmed = false
      end

      if @member_user.phone_confirmed && phone_old != @member_user.phone
        logger.debug "Phone has changed: Old -> #{phone_old.inspect}: New -> #{@member_user.phone.inspect}"
        changed = true
        @member_user.phone_confirmed = false
      end

      if changed && @member_user.save 
        logger.debug "Member object updated successfully with email or phone confirmation changes"     
      end
    	flash[:success] = t(:member_updated, :scope => [:business_validations, :frontend, :member_user])
    	redirect_to member_user_path(@member_user)
    else
      logger.debug "Validation errors. Loading edit view with errors"
    	render 'edit'
    end
  end

  #Test:OK
  def destroy
    logger.info "Loading MemberUser destroy action"
    @member_user = current_resource
    logger.debug "Member attributes hash: #{@member_user.attributes.inspect}" 
    logger.debug "Deleting member and related data..."
    if @member_user.destroy
      logger.debug "Member successfully deleted" 
      logout
      flash[:success] = t(:member_deleted, :scope => [:business_validations, :frontend, :member_user])
      redirect_to root_path
    else
      logger.debug "Error when deleting member"
      logger.fatal "Error when deleting member"
      flash[:success] = t(:member_delete_error, :scope => [:business_validations, :frontend, :member_user])
      redirect_to root_path
    end
  end

  #Test:OK
  def favorites
    logger.info "Loading MemberUser favorites action"
    @member_user = current_resource
    logger.debug "Member attributes hash: #{@member_user.attributes.inspect}" 
    @favorite_stores = @member_user.subscribers.page( params[:page] ).per_page(10) 
    logger.debug "Favorite stores for member: #{@favorite_stores.inspect}" 
  end

  #Show form for completing web profile on top of store profile
  #Test:OK
  def complete_sms_profile
    logger.info "Loading MemberUser complete_sms_profile action"
    token = params[:token]
    if token.present?
      logger.debug "Token is present - #{token.inspect}"
      logger.debug "Continue trying to lookup member record..."
      @member = Member.find_by_access_key(params[:token])
      if @member.nil?
        logger.debug "Error: Member does not exist with that token"
        flash[:alert] = t(:member_not_exist, :scope => [:business_messages, :web_profile])
        redirect_to root_path
      elsif @member.complete
        logger.debug "Error: Member profile already completed"
        flash[:alert] = t(:already_finished, :scope => [:business_messages, :web_profile])
        redirect_to root_path
      else
        logger.debug "Everything OK. We can load form to allow the member to complete profile"
        logger.debug "Set validation mode to web and build user record association"
        #Set validation mode and build user object
        @member.validation_mode = "web"
        @member.build_user()
      end
    else
      logger.debug "Error: No token is present in request"
      logger.fatal "Error: No token is present in request"
      flash[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
      redirect_to root_path
    end
  end

  #Save full profile with all attributes
  #Test:OK
  def update_sms_profile 
    logger.info "Loading MemberUser update_sms_profile action"
    @member = current_resource
    logger.debug "Member attributes hash: #{@member.attributes.inspect}" 
    if @member.update_attributes(params[:member])
        logger.debug "Member saved and updated successfully - attributes hash: #{@member.attributes.inspect}"
        logger.debug "Sending delayed welcome email to new member..."
        MemberMailer.delay.welcome_mail_new_member(@member.id)
        logger.debug "Member email has been sent successfully"
        flash[:success] = t(:success, :scope => [:business_messages, :web_profile])
        redirect_to root_path
    else
      logger.debug "Validation errors. Loading complete_sms_profile with errors"
      render 'complete_sms_profile'      
    end
  end

  private
    def current_resource
      @current_resource ||= Member.find(params[:id]) if params[:id]
    end

end
