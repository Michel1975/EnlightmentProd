class Merchant::SmsHandlerController < Merchant::BaseController
	skip_before_filter :require_login
	skip_before_filter :merchant_user

	def callbackMessage
		notification = MessageNotification.find_by_message_id(params[:sessionid])
		if notification != nil
			status_code_text = params[:rqStatus]
			if !status_code_text.blank?
				status_code = StatusCode.find_by_name(status_code_text)
				if status_code
					notification.status_code = status_code
				else
					#Default fejl
					notification.status_code = StatusCode.find_by_name("5")
				end
				notification.save!
			end
		end
		#Default response with OK status
    	render :nothing => true, :status => :ok
 	end

 	def processMessage
 		text = params[:text].downcase
 		sender = params[:sender]
 		if text.present? && sender.present?
 			if text.include? "stop"
 				stopStoreSubscription(sender, text)
 			else
 				signupMember(sender, text)	
 			end
 		else
 			#Default response with OK status
    		render :nothing => true, :status => :ok 
 		end
 				
 	end

 	def signupMember(sender, text)
 		keyword = text.gsub(/\s+/, "")
 		#Determine if member already exists in database
 		member = Member.find_by_phone(sender) 		
 		if member.nil?
 			member = Member.new(phone: sender, origin: 'store')
 			member.validation_mode = 'store'
 			member.save!
 		end

 		if member
 			merchant_store = MerchantStore.find_by_sms_keyword(keyword)
 			if merchant_store.present?
 				if(merchant_store.subscribers.find_by_member_id(member.id))
 					SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:already_signed_up, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone )	
 				else
 					merchant_store.subscribers.create(member_id: member.id, start_date: Time.now)
 					SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone )
 				end
 			else
 				SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:store_not_found_error, keyword: keyword, :scope => [:business_messages, :store_signup]), member.phone )
 			end
 		end
 		render :nothing => true, :status => :ok
 	end

 	

 	#Vi skal overveje at lave et weblink til dette istedet i alle sms'er som sendes til medlemmet. Der skal måske oprettes en særskilt controller til dette.
 	def stopStoreSubscription(sender, text)
 		member = Member.find_by_phone(sender)
 		if member 			
 			keyword = text.gsub('stop', '').gsub(/\s+/, "").lowercase
 			merchantStore = MerchantStore.find_by_sms_keyword(keyword)
 			if merchantStore
 				if merchantStore.subscribers.find_by_member_id(member.id).destroy
 					SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success, store_name: merchant_store.store_name, :scope => [:business_messages, :opt_out] ), member.phone)	
 				end
 			end
 		end
 		#Default response with OK status
    	render :nothing => true, :status => :ok		
 	end
end
