#encoding: utf-8
class Merchant::SmsHandlerController < Merchant::BaseController
	skip_before_filter :require_login
	skip_before_filter :merchant_user

	#Receiving callback messages from gateway for outbound messages
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
				if status_code
					logger.debug "Match with existing status-code: #{status_code.attributes.inspect}"
					notification.status_code = status_code
				else
					logger.debug "Status code unknown. Inserting default status code = 999"
					#Default fejl-kode indtil videre. Vi skal nok inddrage hele listen på et tidspunkt, så vi har alle data.
					notification.status_code = StatusCode.find_by_name("999")
					logger.debug "Default status code attributes hash: #{notification.status_code.inspect}"
				end
				notification.save!
				logger.debug "Notification saved successfully: #{notification.attributes.inspect}"
			end
		end
		#Default response with OK status
    	render :nothing => true, :status => :ok
 	end

 	#Receiving inbound messages - signups and opt-outs
 	def processMessage
 		logger.info "Loading sms_handler processMessage"
 		text = params[:text].downcase
 		logger.debug "Received text message: #{text.inspect}"
 		sender = params[:sender].strip
 		logger.debug "Received sender number: #{sender.inspect}"
 		#First determine if phone-number is valid  - https://www.debuggex.com - test regex her
 		#Husk at i Rails skal ^ og $ erstattes af henholdsvis \A og \z. Ellers virker det ikke
 		#Regel: Vi tillader forskelige formater når de kommer direkte fra gatewayen. Senere laves de om
 		#i klasse-metoden for member så alle telefonnummer er med +45. Det er vigtigt at alle telefonnumre
 		#er fuldstændig ens i databasen.
 		if text.present? && sender.present? && SMSUtility::SMSFactory.validate_phone_number_incoming?(sender) #/\A(45|\+45|0045)?[1-9][0-9]{7}\z/.match(sender)
 			logger.debug "Sender number and text present. Phone number is valid"
 			logger.debug "Trying to determine type of message: opt-in or opt-out"
 			if text.downcase.include? "stop"
 				logger.debug "Opt-out request received. Calling stopStoreSubscription method"
 				stopStoreSubscription(sender, text)
 			else
 				logger.debug "Opt-in request received. Calling signupMember method"
 				signupMember(sender, text)	
 			end
 		else
 			#To-Do: Log invalid phone number
 			#Default response with OK status
    		render :nothing => true, :status => :ok 
 		end	
 	end

 	def signupMember(sender, text)
 		logger.info "Loading sms_handler signupMember"
 		keyword = text.gsub(/\s+/, "")
 		logger.debug "Keyword received: #{keyword.inspect}"
 		#Determine if member already exists in database. First, incoming phone is standardized with +45 notation.
 		converted_phone_number = SMSUtility::SMSFactory.convert_phone_number(sender)
 		logger.debug "Converted phone number: #{converted_phone_number.inspect}"
 		logger.debug "Trying to find existing member in database from phone number"
 		member = Member.find_by_phone(converted_phone_number) 		
 		if member.nil?
 			logger.debug "Member does NOT exist in database. New member is created"
 			member = Member.new(phone: converted_phone_number, origin: 'store')
 			member.validation_mode = 'store'
 			member.save!
 			logger.debug "New member saved successfully: #{member.attributes.inspect}"
 		end

 		if member
 			merchant_store = MerchantStore.find_by_sms_keyword(keyword)
 			if merchant_store.present?
 				logger.debug "Merchant-store look-up: #{merchant_store.attributes.inspect}"
 				subscriber = merchant_store.subscribers.find_by_member_id(member.id)
 				logger.debug "Calling processSignup method"
 				#Make call to base_controller method for detailed signup
 				processSignup(member, subscriber, merchant_store, "store")
 			else
 				logger.debug "Merchant-store not found from received keyword"
 				logger.fatal "Merchant-store not found from received keyword"
 				#Log all keywords that doesn't match stores
 				message_error = MessageError.create!(recipient: sender, name: keyword)
 				logger.debug "Message error entry created: #{message_error.inspect}"
 				#Her skal vi overveje om vi udsender sms'er. Vi kan evt. tælle fejl pr. telefonnummer og blokere ved for mange fejl
 				#SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:store_not_found_error, keyword: keyword, :scope => [:business_messages, :store_signup]), member.phone )
 			end
 		end
 		render :nothing => true, :status => :ok
 	end

 	#Vi skal overveje at lave et weblink til dette istedet i alle sms'er som sendes til medlemmet. Der skal måske oprettes en særskilt controller til dette.
 	def stopStoreSubscription(sender, text)
 		logger.info "Loading sms_handler stopStoreSubscription"
 		logger.debug "Trying to find existing member in database from phone number"
 		member = Member.find_by_phone(sender)
 		if member 	
 			logger.debug "Member found in database: #{member.attributes.inspect}"		
 			keyword = text.gsub('stop', '').gsub(/\s+/, "").downcase
 			logger.debug "Keyword: #{keyword.inspect}"
 			logger.debug "Trying to find merchantstore in database from keyword"
 			merchantStore = MerchantStore.find_by_sms_keyword(keyword)
 			if merchantStore
 				logger.debug "Merchant-store found in database: #{merchantStore.attributes.inspect}"
 				logger.debug "Trying to find subscriber record in database from keyword"
 				subscriber = merchantStore.subscribers.find_by_member_id(member.id) 
 				if subscriber && SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success, store_name: merchantStore.store_name, :scope => [:business_messages, :opt_out] ), member.phone, merchantStore)	
 					logger.debug "Subscriber record found: #{subscriber.attributes.inspect}"
 					logger.debug "Confirmation message sent to member"
 					subscriber.opt_out.save!
 					logger.debug "Subscriber record saved successfully: #{subscriber.attributes.inspect}"
 				end
 			else
 				logger.debug "Merchant-store not found from received keyword"
 				logger.fatal "Merchant-store not found from received keyword"
 				#Log all keywords that doesn't match stores
 				message_error = MessageError.create!(recipient: sender, name: keyword)
 				logger.debug "Message error entry created: #{message_error.inspect}"	
 			end
 		end
 		#Default response with OK status
    	render :nothing => true, :status => :ok		
 	end
end
