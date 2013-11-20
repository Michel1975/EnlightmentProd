class Merchant::MerchantMembersController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
	
	#To be used from merchant portal when manually creating new subscriber from scrath - more logic needed
	def new
		logger.info "Loading merchant_member new action"
		@member = Member.new
	end

	#To be used from merchant portal when manually creating new subscriber from scrath - more logic needed
	def create
		logger.info "Loading merchant_member create action"
		phone_number = params[:member][:phone]
		logger.debug "Trying to find another member with same phone number: #{phone_number.inspect}"
		@member = Member.find_by_phone(SMSUtility::SMSFactory.convert_phone_number(phone_number))
		if @member.nil?
			logger.debug "Phone does not exist in database...creating new member"
			@member = Member.new(params[:member])
			@member.validation_mode = 'store'
			@member.origin = 'store'
			if !@member.save
				return render action: 'new'
			end
			logger.debug "New member saved succesfully: #{@member.attributes.inspect}"
		end
		logger.debug "Trying to determine if member is already a subscriber"
		subscriber = current_merchant_store.subscribers.find_by_member_id(@member)
		if subscriber 
			logger.debug "Error: Member is already a subscriber. Loading new view with errors"
			flash.now[:alert] = t(:member_already_exists, :scope => [:business_validations, :merchant_member]) 
			render action: 'new'
		else
			logger.debug "Member is not a subscriber. New subscriber record must be created"
			logger.debug "Calling process-signup method"
			#Make call to base_controller class
			processSignup(@member, current_merchant_store, "store")
			flash[:success] = t(:member_added, :scope => [:business_validations, :merchant_member])
			redirect_to merchant_subscribers_path
		end
    end
end#end class
