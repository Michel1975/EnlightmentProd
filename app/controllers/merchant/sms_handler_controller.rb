#encoding: utf-8
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
					#Default fejl-kode indtil videre. Vi skal nok inddrage hele listen på et tidspunkt, så vi har alle data.
					notification.status_code = StatusCode.find_by_name("999")
				end
				notification.save!
			end
		end
		#Default response with OK status
    	render :nothing => true, :status => :ok
 	end

 	def processMessage
 		text = params[:text].downcase
 		sender = params[:sender].strip
 		#First determine if phone-number is valid  - https://www.debuggex.com - test regex her
 		#Husk at i Rails skal ^ og $ erstattes af henholdsvis \A og \z. Ellers virker det ikke
 		#Regel: Vi tillader forskelige formater når de kommer direkte fra gatewayen. Senere laves de om
 		#i klasse-metoden for member så alle telefonnummer er med +45. Det er vigtigt at alle telefonnumre
 		#er fuldstændig ens i databasen.
 		if text.present? && sender.present? && SMSUtility::SMSFactory.validate_phone_number_incoming(sender) #/\A(45|\+45|0045)?[1-9][0-9]{7}\z/.match(sender)
 			if text.downcase.include? "stop"
 				stopStoreSubscription(sender, text)
 			else
 				signupMember(sender, text)	
 			end
 		else
 			#To-Do: Log invalid phone number
 			#Default response with OK status
    		render :nothing => true, :status => :ok 
 		end	
 	end

 	def signupMember(sender, text)
 		keyword = text.gsub(/\s+/, "")
 		#Determine if member already exists in database. First, incoming phone is standardized with +45 notation.
 		converted_phone_number = SMSUtility::SMSFactory.convert_phone_number(sender)
 		member = Member.find_by_phone(converted_phone_number) 		
 		if member.nil?
 			member = Member.new(phone: converted_phone_number, origin: 'store')
 			member.validation_mode = 'store'
 			member.save!
 		end

 		if member
 			merchant_store = MerchantStore.find_by_sms_keyword(keyword)
 			if merchant_store.present?
 				subscriber = merchant_store.subscribers.find_by_member_id(member.id)
 				if(subscriber && subscriber.active)
 					SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:already_signed_up, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone )	
 				else
 					#Make call to base_controller method for detailed signup
 					processSignup(member, subscriber, merchant_store, "store")
 					#merchant_store.subscribers.create(member_id: member.id, start_date: Time.now)
 					#SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone )
 				end
 			else
 				#Log all keywords that doesn't match stores
 				MessageError.create!(recipient: sender, name: keyword)
 				#Her skal vi overveje om vi udsender sms'er. Vi kan evt. tælle fejl pr. telefonnummer og blokere ved for mange fejl
 				#SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:store_not_found_error, keyword: keyword, :scope => [:business_messages, :store_signup]), member.phone )
 			end
 		end
 		render :nothing => true, :status => :ok
 	end

 	#Vi skal overveje at lave et weblink til dette istedet i alle sms'er som sendes til medlemmet. Der skal måske oprettes en særskilt controller til dette.
 	def stopStoreSubscription(sender, text)
 		member = Member.find_by_phone(sender)
 		if member 			
 			keyword = text.gsub('stop', '').gsub(/\s+/, "").downcase
 			merchantStore = MerchantStore.find_by_sms_keyword(keyword)
 			if merchantStore
 				subscriber = merchantStore.subscribers.find_by_member_id(member.id)
 				if subscriber && SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( t(:success, store_name: merchantStore.store_name, :scope => [:business_messages, :opt_out] ), member.phone)	
 					subscriber.opt_out.save!
 				end
 			else
 				#Log all keywords that doesn't match stores
 				MessageError.create!(recipient: sender, name: keyword)	
 			end
 		end
 		#Default response with OK status
    	render :nothing => true, :status => :ok		
 	end
end
