#encoding: utf-8
class Merchant::SmsHandlerController < Merchant::BaseController
	skip_before_filter :require_login
	skip_before_filter :authorize
	skip_before_filter :merchant_user

	#Receiving callback messages from gateway for outbound messages
	#Test:OK
	def callbackMessage
		logger.info "Loading sms_handler callbackMessage"
		logger.info "Trying to find existing notification record in database"
		notification = MessageNotification.find_by_message_id(params[:sessionid])
		if notification != nil
			logger.debug "Notification found in database: #{notification.inspect}"
			status_code_text = params[:rqStatus]
			if !status_code_text.blank?
				logger.debug "Received raw status-code: #{status_code_text.inspect}"
				status_code = StatusCode.find_by_name(status_code_text)
				if status_code.present?
					logger.debug "Match OK with existing status-code: #{status_code.attributes.inspect}"
					notification.status_code = status_code
				else
					logger.debug "Status code unknown. Inserting default status code = 999"
					#Default status code is used. Custom code 999 is used for messages which not could be sent
					notification.status_code = StatusCode.find_by_name("999")
					logger.debug "Default status code attributes hash: #{notification.status_code.inspect}"
				end
				if notification.save
					logger.info "Notification saved successfully: #{notification.attributes.inspect}"
				else
					logger.fatal "Error: Notification NOT saved due to unknown errors"
					logger.debug "Error: Notification NOT saved due to unknown errors"
				end
			else
				logger.debug "Missing attribute param: rqStatus"	
			end
		else
			logger.debug "Notification NOT found. Cause: Unknown message status received"	
		end

		#Default response with OK status
    	render :nothing => true, :status => :ok
 	end

 	#Receiving inbound messages - signups and opt-outs
 	#Test:OK
 	def processMessage
 		logger.info "Loading sms_handler processMessage"
 		text = params[:text]
 		logger.debug "Received text message: #{text.inspect}"
 		sender = params[:sender]
 		logger.debug "Received sender number: #{sender.inspect}"
 		#First determine if phone-number is valid  - https://www.debuggex.com - test regex her
 		#Husk at i Rails skal ^ og $ erstattes af henholdsvis \A og \z. Ellers virker det ikke
 		#Regel: Vi tillader forskelige formater når de kommer direkte fra gatewayen. Senere laves de om
 		#i klasse-metoden for member så alle telefonnumre er med +45. Det er vigtigt at alle telefonnumre
 		#er fuldstændig ens i databasen.
 		if text.present? && sender.present? 
 			logger.debug "Sender number and text present. Proceeding...."
 			text = text.downcase
 			logger.debug "Text message downcased: #{text.inspect}"
 			sender = sender.strip
 			logger.debug "Sender stripped for whitespaces: #{sender.inspect}"

 			logger.debug "Checking if incoming phone number is valid"
 			if SMSUtility::SMSFactory.validate_phone_number_incoming?(sender) #/\A(45|\+45|0045)?[1-9][0-9]{7}\z/.match(sender)
	 			logger.debug "Incoming phone number valid"

	 			logger.debug "Trying to determine type of message: opt-in or opt-out"
	 			if text.downcase.include? "stop"
	 				logger.debug "Opt-out request received. Calling stopStoreSubscription method..background process"
	 				SMSUtility::BackgroundWorker.new.delay.stopStoreSubscription(sender, text)
	 			else
	 				logger.debug "Opt-in request received. Calling signupMember method...background process"
	 				SMSUtility::BackgroundWorker.new.delay.signupMember(sender, text)
	 			end
	 		else
	 			logger.fatal "Error: Incoming phone number not valid"
	 			logger.debug "Error: Incoming phone number not valid"
	 			MessageError.create!(recipient: sender, text: text, error_type: "invalid_phone_number")
	 		end
 		else
 			logger.fatal "Error: Missing phone number or text"
	 		logger.debug "Error: Missing phone number or text"
 			MessageError.create!(recipient: sender, text: text, error_type: "missing_attributes")
 			#Default response with OK status
 		end
 		#Return this no matter what
 		render :nothing => true, :status => :ok 	
 	end

=begin moved to smsutility for better usage in worker threads
 	protected

 	def signupMember(sender, text)
 		logger.info "Loading sms_handler signupMember"
 		keyword = text.gsub(/\s+/, "")
 		logger.debug "Keyword parameter received...removed whitespaces: #{keyword.inspect}"
 		logger.debug "Sender parameter received: #{sender.inspect}"
 		
 		#Determine if member already exists in database. First, incoming phone is standardized with +45 notation.
 		converted_phone_number = SMSUtility::SMSFactory.convert_phone_number(sender)
 		logger.debug "Converted phone number: #{converted_phone_number.inspect}"
 		logger.debug "Trying to find existing member in database from phone number"
 		member = Member.find_by_phone(converted_phone_number) 		
 		if member.nil?
 			logger.debug "Member does NOT exist in database. New member is created"
 			member = Member.new(phone: converted_phone_number, origin: 'store')
 			member.validation_mode = 'store'
 			if member.save
 				logger.debug "New member saved successfully: #{member.attributes.inspect}"
 			else
 				logger.debug "Error when saving new member created in-store"
 				logger.fatal "Error when saving new member created in-store"	
 			end
 		end

 		if member.present?
 			merchant_store = MerchantStore.active.find_by_sms_keyword(keyword)
 			if merchant_store.present?
 				logger.debug "Merchant-store found: #{merchant_store.attributes.inspect}"
 				logger.debug "Calling processSignup method..."
 				#Make call to base_controller method for detailed signup
 				processSignup(member, merchant_store, "store")
 			else
 				logger.debug "Error: Merchant-store NOT found from received keyword"
 				logger.fatal "Error: Merchant-store NOT found from received keyword"
 				
 				#Log all keywords that doesn't match stores
 				message_error = MessageError.create!(recipient: sender, name: keyword, error_type: "invalid_keyword")
 				logger.debug "Message error entry created: #{message_error.inspect}"
 				#We don't respond to sms gateway with errors - for now - save money :-)
 			end
 		end
 		#invalid: render :nothing => true, :status => :ok
 	end

 	#Vi skal overveje at lave et weblink til dette istedet i alle sms'er som sendes til medlemmet. Der skal måske oprettes en særskilt controller til dette.
 	def stopStoreSubscription(sender, text)
 		logger.info "Loading sms_handler stopStoreSubscription"

 		#Determine if member already exists in database. First, incoming phone is standardized with +45 notation.
 		converted_phone_number = SMSUtility::SMSFactory.convert_phone_number(sender)
 		logger.debug "Converted phone number: #{converted_phone_number.inspect}"
 		logger.debug "Trying to find existing member in database from phone number"
 		member = Member.find_by_phone(converted_phone_number)
 		if member.present?
 			logger.debug "Member found in database: #{member.attributes.inspect}"		
 			keyword = text.gsub('stop', '').gsub(/\s+/, "").downcase
 			logger.debug "Keyword after downcase and remove whitespace: #{keyword.inspect}"
 			
 			logger.debug "Trying to find merchantstore in database from keyword"
 			merchantStore = MerchantStore.find_by_sms_keyword(keyword)
 			if merchantStore.present?
 				logger.debug "Merchant-store found in database: #{merchantStore.attributes.inspect}"
 				logger.debug "Trying to find subscriber record in database from keyword"
 				subscriber = merchantStore.subscribers.find_by_member_id(member.id)
 				if subscriber && subscriber.destroy 
 					logger.debug "Subscriber record found. Proceeding with deletion of membership..."

 					logger.debug "Subscriber record deleted. Sending message notification to user"
 					if SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success, store_name: merchantStore.store_name, :scope => [:business_messages, :opt_out] ), member.phone, merchantStore)
 						logger.debug "Confirmation message sent to member about opt-out"
 						logger.debug "Analyzing if member should be deleted too..in case of no subscribers and pure store-profile"
 						if member.subscribers.empty? && !member.complete
 							logger.debug "Member has no subscribers and is a pure store-only profile..,go ahead and delete"
 							if member.destroy
 								logger.debug "Member deleted successfully"
 							end
 						end
 					else
 						logger.debug "Error when sending confirmation message sent to member about opt-out"
 						logger.fatal "Error when sending confirmation message sent to member about opt-out"
 					end
 				else
 					logger.debug "Subscriber not found. Could not destroy record."	
 					logger.fatal "Subscriber not found. Could not destroy record."
 				end
 			else
 				logger.debug "Merchant-store not found from received keyword"
 				logger.fatal "Merchant-store not found from received keyword"
 				#Log all keywords that doesn't match stores
 				MessageError.create(recipient: sender, text: keyword, error_type: "invalid_keyword")
 			end
 		else
 			logger.debug "Member NOT found from phone number"
 			logger.fatal "Member NOT found from phone number"	
 		end
 		#Default response with OK status
    	#invalid: render :nothing => true, :status => :ok		
 	end#end stopsubscription
=end

end#end controller class
