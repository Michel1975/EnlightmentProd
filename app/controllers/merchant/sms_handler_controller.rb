class Merchant::SmsHandlerController < Merchant::BaseController

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
 				merchant_store.subscribers.create(member_id: member.id, start_date: Time.now)
 				#To-do: Lav en template fil			
 				sendSingleMessageInstant?("Hejsa,\nvelkommen som nyt medlem i vores kundeklub. Du vil løbende modtage spændende tilbud og nyheder fra vores butik\n\nMed venlig hilsen\n#{merchant_store.store_name}", member.phone)	
 			else
 				sendSingleMessageInstant?("Hejsa,\nder findes ikke en Club Novus partnerbutik med teksten #{keyword}.\nTjek venligst om teksten er korrekt og prøv igen.\n\nMed venlig hilsen\nClub Novus", member.phone)
 			end
 		end
 		render :nothing => true, :status => :ok
 	end

 	#Vi skal overveje at lave et weblink til dette istedet i alle sms'er som sendes til medlemmet. Der skal måske oprettes en særskilt controller til dette.
 	def stopStoreSubscription(sender, text)
 		member = Member.find_by_phone(sender)
 		if member 			
 			keyword = text.gsub('stop', '').gsub(/\s+/, "")
 			merchantStore = MerchantStore.find_by_keyword(keyword)
 			if merchantStore
 				merchantStore.subscribers.find_by_member_id(member.id).destroy
 				sendSingleMessageInstant?("Hejsa,\ndu vil nu ikke længere modtage notifikationer fra #{merchantStore.store_name}.\n\nMvh\n Club Novus", member.phone)	
 			end
 		end
 		render :nothing => true 		
 	end
end
