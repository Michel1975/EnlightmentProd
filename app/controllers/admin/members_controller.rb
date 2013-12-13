#encoding: utf-8
class Admin::MembersController < Admin::BaseController
	
	#Test: OK 
	def index
		logger.info "Loading Members index action"
		
		@search = false
		logger.debug "Search flag: #{@search.inspect}"
		#Scoped is a special method to return all members in normal format without causing issues in will-paginate
		@members = Member.scoped.page(params[:page]).per_page(15)
		logger.debug "Members - attributes hash: #{@members.inspect}"
	end

	#Test: OK
	def search_members
	    logger.info "Loading Members search_members action"
	    @name = params[:name]
	    logger.debug "Search parameter - name: #{@name.inspect}"
	    @phone = params[:phone]
	    logger.debug "Search parameter - phone: #{@phone.inspect}"
	    @search = true
	    logger.debug "Search flag: #{@search.inspect}"
	    @members = Member.search(@name, @phone).page(params[:page]).per_page(15)
	    logger.debug "Search result: #{@members.inspect}"
	    logger.debug "Loading index view with search result..."
	    render :index
  	end

  	#Test: OK
  	def send_mobile_confirmation_with_sms 
	    logger.info "Loading MemberUser send_mobile_confirmation_with_sms action"
	    @member = current_resource
	    logger.debug "Member found - attributes hash: #{@member.attributes.inspect}"
	    message = t(:sms_code_message, sms_code: @member.phone_confirmation_code, :scope => [:business_messages, :web_profile])
	    logger.debug "SMS message to be sent: #{message.inspect}"
	    if SMSUtility::SMSFactory.sendSingleAdminMessageInstant?(message, @member.phone, nil )
	      logger.debug "SMS message sent successfully to #{@member.phone}"
	      flash[:success] = t(:sms_confirmation_sent, phone_number: @member.phone, :scope => [:business_validations, :backend, :member])
	      redirect_to admin_member_path(@member)
	    else
	      logger.debug "Error when sending sms to member phone"
	      logger.fatal "Error when sending sms to member phone"
	      flash[:alert] = t(:sms_confirmation_error, :scope => [:business_validations, :backend, :member])
	      redirect_to admin_member_path(@member)
	    end
  	end

  	#Test: OK
  	def resend_email_confirmation
	    logger.info "Loading Members resend_email_confirmation action"
	    @member = current_resource
	    logger.debug "Member found - attributes hash: #{@member.attributes.inspect}"
	    #Only send if email is not confirmed
	    if !@member.email_confirmed
	      logger.debug "Email is not confirmed - sending new activation link"
	      MemberMailer.delay.email_confirmation_link(@member.id)
	      flash[:success] = t(:email_confirmation_sent, :scope => [:business_validations, :backend, :member])
	      redirect_to admin_member_path(@member)
	    else
	      logger.debug "Email already confirmed. Reloading view with notification"
	      flash[:alert] = t(:email_confirmation_error, :scope => [:business_validations, :backend, :member])
	      redirect_to admin_member_path(@member)
	    end
  	end

  	#Test: OK 
	def show
		logger.info "Loading Members show action"
		@member = current_resource
		logger.debug "Member - attributes hash: #{@member.attributes.inspect}"

		@subscriber_stores = @member.subscribers.page( params[:page] ).per_page(15)
		logger.debug "Subscriber stores - attributes hash: #{@subscriber_stores.inspect}"
	end

	#Test: OK
	def remove_subscriber
		logger.info "Loading Members remove_subscriber action"
  		subscriber = Subscriber.find(params[:id])
  		logger.debug "Subscriber - attributes hash: #{subscriber.attributes.inspect}"
  		member = Member.find(subscriber.member_id)
  		logger.debug "Member - attributes hash: #{member.attributes.inspect}"
		if subscriber.destroy
			logger.debug "Subscriber deleted successfully"
			flash[:success] = t(:subscriber_removed, :scope => [:business_validations, :backend, :subscriber])
    		redirect_to [:admin, member]
		else
			logger.debug "Error when deleting subscriber"
			logger.fatal "Error when deleting subscriber"
			flash[:error] = t(:subscriber_remove_error, :scope => [:business_validations, :backend, :subscriber])
    		redirect_to [:admin, member]
		end
	end

	#Test: OK
	def destroy
		logger.info "Loading Members destroy action"
  		member = current_resource
  		logger.debug "Member - attributes hash: #{member.attributes.inspect}"
		if member.destroy
			logger.debug "Member successfully deleted"
			flash[:success] = t(:member_removed, :scope => [:business_validations, :backend, :member])
    		redirect_to admin_members_path
		else
			logger.debug "Error deleting member. Redirecting to member list"
			logger.fatal "Error deleting member. Redirecting to member list"
			flash[:error] = t(:member_remove_error, :scope => [:business_validations, :backend, :member])
    		redirect_to admin_members_path
		end
	end

	private
    	def current_resource
      		@current_resource ||= Member.find(params[:id]) if params[:id]
    	end

end
