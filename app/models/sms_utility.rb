#encoding: utf-8
#Utility class with SMS handling methods
module SMSUtility
  #This regXP is used for incoming phone numbers from gateway and forms.
  VALID_PHONE_REGEX_INCOMING = %r{\A(45|\+45|0045)?[1-9][0-9]{7}\z}

  #This reflects the standard in database after conversion
  VALID_PHONE_REGEX_STANDARD = %r{\A(\+45){1}[1-9][0-9]{7}\z}
  #old2:VALID_PHONE_REGEX_STANDARD = %r{\A(\+45)?[1-9][0-9]{7}\z}
  #old:VALID_PHONE_REGEX_STANDARD = %r{\A\+45?[1-9][0-9]{7}\z}

  #This reflects the standard characters for sms messages
  VALID_SMS_MESSAGE = %r{\A[\w\s@?£!1$"#è?¤é%ù&\\()*:Ø+;øÆ,<æ\-=Å.>å\/§\']+\z}

  TOTAL_MESSAGES_MONTH = ENV["SMS_LIMIT_TOTAL"]
  STORE_TOTAL_MESSAGES_MONTH = ENV["SMS_LIMIT_STORE"]

class SMSFactory

  #Primarily used by search functionality
  def self.convert_phone_number(phone_number)
    Rails.logger.info "Into convert_phone_number"
    Rails.logger.debug "Phone number parameter: #{phone_number.inspect}"
    if validate_phone_number_converted?(phone_number)
      Rails.logger.debug "Phone number already valid. Returning..."
      return phone_number
    elsif validate_phone_number_incoming?(phone_number)
      Rails.logger.debug "Valid incoming phone number, but does not yet comply with standard. Need to convert to standard..."
      if phone_number.to_s.size > 8
        Rails.logger.debug "Phone length larger than 8 characters"
        return phone_number = "+45" + phone_number.sub(/\A(0045|45)/, "").to_s.strip
      else
        Rails.logger.debug "Phone length is up to 8 characters"
        return phone_number = "+45" + phone_number.to_s.strip
      end
    else
      Rails.logger.debug "Error: Phone does not match incoming match pattern. Convert aborted!" 
      Rails.logger.fatal "Error: Phone does not match incoming match pattern. Convert aborted!"
    end
  end

  def self.validate_sms?(message)
    Rails.logger.info "Into validate_sms?"
    #Reduceret udgave af http://stackoverflow.com/questions/15866068/regex-to-match-gsm-character-set
    #Testet med http://rubular.com
    #%r gør hele forskellen- dette skyldes at %r er beregnet til netop regulære udtryk
    result = message.match(SMSUtility::VALID_SMS_MESSAGE)
    Rails.logger.debug "Result: #{result.inspect}"
    return result
  end

  def self.validate_phone_number_converted?(phone_number)
    Rails.logger.info "Into validate_phone_number_converted?"
    result = phone_number.to_s.match(SMSUtility::VALID_PHONE_REGEX_STANDARD)
    Rails.logger.debug "Result: #{result.inspect}"
    return result
  end

  def self.validate_phone_number_incoming?(phone_number)
    Rails.logger.info "Into validate_phone_number_incoming?"
    result = phone_number.to_s.match(SMSUtility::VALID_PHONE_REGEX_INCOMING)
    Rails.logger.debug "Result: #{result.inspect}"
    return result
  end

  def self.validate_message_limits?(message_count)
    Rails.logger.info "Into validate_message_limits?"
    Rails.logger.debug "Number of messages in this order: #{message_count.inspect}"
    no_total_messages = SMSUtility::TOTAL_MESSAGES_MONTH.to_i
    Rails.logger.debug "Current total monthly message limit for all stores: #{no_total_messages.inspect}"
    no_already_sent_messages = MessageNotification.month_total_messages.count
    Rails.logger.debug "Total number of messages sent this month before new message: #{no_already_sent_messages.inspect}"
    result = ( no_already_sent_messages + message_count) <= no_total_messages
    Rails.logger.debug "Result: #{result.inspect}"
    return result
  end

	#START SAVON
	#Afsendelse af sms til en enkelt person (typisk admin eller direkte kommunikation til et medlem)
  def self.sendSingleMessageInstant?(message, recipient, merchant_store)
    Rails.logger.info "Into sendSingleMessageInstant?"
    if validate_message_limits?(1)
      Rails.logger.debug "Total Message limit not broken. Everything is OK, message can be sent"
      Rails.logger.debug "Message parameter: #{message.inspect}"
      Rails.logger.debug "Recipient parameter: #{recipient.inspect}"
      Rails.logger.debug "Merchant-store parameter: #{merchant_store.attributes.inspect}" if merchant_store
      messageContent = prepareMessage('InstantSingleMessage', nil, recipient, message, merchant_store) 
      Rails.logger.debug "Message payload prepared for gateway: #{messageContent.inspect}"
      result = sendMessage?('push', messageContent) 
      Rails.logger.debug "Message transmission result: #{result.inspect}" 
      return true 
    else
      Rails.logger.debug "Total Message limit broken. Message CANNOT be sent"
      Rails.logger.fatal "Total Message limit broken. Message CANNOT be sent"
      return false
    end
  end

  #Afsendelse af sms'er i forbindelse med tilmelding og afmelding m.v. Her er Club Novus provider
  def self.sendSingleAdminMessageInstant?(message, recipient, merchant_store)
    Rails.logger.info "Into sendSingleAdminMessageInstant?"
    if validate_message_limits?(1)
      Rails.logger.debug "Total Message limit not broken. Everything is OK, message can be sent"
      Rails.logger.debug "Message parameter: #{message.inspect}"
      Rails.logger.debug "Recipient parameter: #{recipient.inspect}"
      Rails.logger.debug "Merchant-store parameter: #{merchant_store.attributes.inspect}" if merchant_store
      messageContent = prepareMessage('InstantSingleAdminMessage', nil, recipient, message, merchant_store) 
      Rails.logger.debug "Message payload prepared for gateway: #{messageContent.inspect}"   
      result = sendMessage?('push', messageContent)  
      if result
        Rails.logger.debug "Message sent - transmission result: #{result.inspect}"
        return true 
      else
        Rails.logger.fatal "Error: Message not sent due to unknown reasons"
        return false
      end
    else
      Rails.logger.debug "Total Message limit broken. Message CANNOT be sent"
      Rails.logger.fatal "Total Message limit broken. Message CANNOT be sent"
      return false
    end
  end

  #Kampagne metoder
  def self.sendOfferReminderScheduled?(campaign, merchant_store)
    Rails.logger.info "Into sendOfferReminderScheduled?"
    if validate_message_limits?(campaign.campaign_members.count)
      Rails.logger.debug "Total Message limit not broken. Everything is OK, campaign can be scheduled"
      Rails.logger.debug "Campaign parameter: #{campaign.attributes.inspect}"
      Rails.logger.debug "Merchant-store parameter: #{merchant_store.attributes.inspect}" if merchant_store
      messageContent = prepareMessage('CreateCampaignScheduled', campaign, nil, nil, merchant_store)
      Rails.logger.debug "Campaign payload prepared for gateway: #{messageContent.inspect}"
      result = sendMessage?('push_scheduled', messageContent) 
      if result
        Rails.logger.debug "Message sent - transmission result: #{result.inspect}"
        return true 
      else
        Rails.logger.fatal "Error: Message not sent due to unknown reasons"
        return false
      end
    else
      Rails.logger.debug "Total Message limit broken. Message CANNOT be sent"
      Rails.logger.fatal "Total Message limit broken. Message CANNOT be sent"
      return false
    end
  end

  def self.reschduleOfferReminder?(campaign)
    Rails.logger.info "Into reschduleOfferReminder?"
    Rails.logger.debug "Campaign parameter: #{campaign.attributes.inspect}"
    messageContent = prepareMessage('RescheduleCampaign', campaign, nil, nil, nil)
    Rails.logger.debug "Campaign reschedule payload prepared for gateway: #{messageContent.inspect}"
    result = sendMessage?('reschedule_group', messageContent) 
    if result
        Rails.logger.debug "Message sent - transmission result: #{result.inspect}"
        return true 
    else
      Rails.logger.fatal "Error: Message not sent due to unknown reasons"
      return false
    end
  end

  def self.cancelScheduledOfferReminder?(campaign)
    Rails.logger.info "Into cancelScheduledOfferReminder?"
    Rails.logger.debug "Campaign parameter: #{campaign.attributes.inspect}"
    messageContent = prepareMessage('CancelCampaign', campaign, nil, nil, nil)
    Rails.logger.debug "Campaign cancel payload prepared for gateway: #{messageContent.inspect}"
    result = sendMessage?('cancel_group', messageContent)
    if result
        Rails.logger.debug "Message sent - transmission result: #{result.inspect}"
        return true 
    else
      Rails.logger.fatal "Error: Message not sent due to unknown reasons"
      return false
    end
  end  

  private

  def self.prepareMessage(mode, campaign, recipient, message, merchant_store)
    Rails.logger.info "Into prepareMessage"
    Rails.logger.debug "Running mode: #{mode.inspect}"
    
    xml_body = ""
    default_status_code = StatusCode.find_by_name("500")
    Rails.logger.debug "Default status code lookup: #{default_status_code.attributes.inspect}" if default_status_code.present?
    
    if mode == 'CreateCampaignScheduled'
      recipientString = ""

      #Insert placeholder macro for stop-link
      message = campaign.message + "\n%StopLink%"
      campaign.campaign_members.each do |campaign_member|
        #Generate safe message-id from log method
        recipient = campaign_member.subscriber.member.phone
        message_id = register_message_notification(campaign, recipient, merchant_store, default_status_code, "campaign")
        recipientString += "<to id='#{message_id}' StopLink='#{campaign_member.subscriber.opt_out_link_sms}' >" + recipient + "</to>" 
      end
      recipientXml = "<recipients>" + recipientString + "</recipients>"     
      stringXml = "<bulk>" +    
      "<message>" + HTMLEntities.new.encode(message) + "</message>" +
      "<header><from>1276222</from>" +
      "<GroupID>" + campaign.message_group_id + "</GroupID></header>" + 
      recipientXml + "</bulk>"      
      builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
      builder.tag!("myb:iGatewayId", ENV["SMS_GATEWAY_ID"])
      builder.tag!("myb:sAlertXml", stringXml)
      builder.tag!("myb:sDateTimeToSend",  campaign.activation_time.strftime("%Y-%m-%dT%H:%M:%S")) 
      builder.tag!("myb:timeZone", 'Denmark')
      builder.tag!("myb:MerchantId", merchant_store.id)
  elsif mode == 'CancelCampaign'    
    builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
    builder.tag!("myb:iGatewayId", ENV["SMS_GATEWAY_ID"])
    builder.tag!("myb:sMessageGroupId", campaign.message_group_id)
  elsif mode == 'RescheduleCampaign'
    builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
    builder.tag!("myb:iGatewayId", ENV["SMS_GATEWAY_ID"])
    builder.tag!("myb:sMessageGroupId",  campaign.message_group_id)
    builder.tag!("myb:sDateTimeToSend", campaign.activation_time.strftime("%Y-%m-%dT%H:%M:%S") ) 
    builder.tag!("myb:timeZone", 'Denmark') 
  elsif mode == 'InstantSingleMessage' || mode == 'InstantSingleAdminMessage'
    #Insert stop-link for single direct messages
    if mode == 'InstantSingleMessage' 
      message_id = register_message_notification(nil, recipient, merchant_store, default_status_code, "single")
    else
      message_id = register_message_notification(nil, recipient, merchant_store, default_status_code, "admin")  
    end
    #Format payload containing message parameters.
    stringXml = "<xml><item>" +    
      "<message>" + HTMLEntities.new.encode(message) + "</message>" +
      "<messageid>" + message_id + "</messageid>" +
      "<recipient>" + recipient + "</recipient>" +
      #ekstra tilføjelse med from
      "<from>1276222</from>" +
      "</item></xml>"      
      builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
      builder.tag!("myb:iGatewayId", ENV["SMS_GATEWAY_ID"])
      #Club Novus pays for all sign-up and opt-out sms messages
      payer_id = mode == 'InstantSingleMessage' ? merchant_store.id : "Club Novus"
      builder.tag!("myb:MerchantId", payer_id)   
      builder.tag!("myb:sAlertXml", stringXml) 
      #Message_status.create(messageid: message_id, message_type: 'SMS', recipient: recipient.phone) 
  end
  return xml_body 
end
  
  def self.sendMessage?(method, messageContent)
    @gateway_status = ENV['SMS_GATEWAY_ACTIVE']
    if @gateway_status == 'true'
      Rails.logger.info "Gateway active. Proceeding with sending message..."
      Rails.logger.info "Into sendMessage?"
      #wsdl_file = "http://sdk.ecmr.biz/src/gateway.asmx?wsdl"  
      wsdl_file = File.read(Rails.root.join("config/wsdl/CIMMobil_ssl.xml"))
      #wsdl_file = "http://127.0.0.1:8088/mockGatewaySoap12?wsdl"
      #wsdl_file =

      client = Savon.client(  env_namespace: :soap, wsdl: wsdl_file, raise_errors: true, ssl_verify_mode: :none, 
                    pretty_print_xml: true, namespaces: { "xmlns:myb" => "http://myblipz.com" },
                    soap_version:2, soap_header: %{<myb:AuthHeader><myb:Login>#{ENV["SMS_GATEWAY_USER_NAME"]}</myb:Login><myb:Password>#{ENV["SMS_GATEWAY_PASSWORD"]}</myb:Password></myb:AuthHeader>})
      result = client.call(method.to_sym, message: messageContent )
      Rails.logger.debug "Transmission result: #{result.inspect}" 
      return result 
      #return true
    else
      Rails.logger.debug "Gateway NOT active. Message NOT sent"
      return false
    end 
  end
  #END SAVON

  #This method is invoked once for each recipient in campaign or for single message.
  def self.register_message_notification(campaign, recipient, merchant_store, default_status_code, source)
    Rails.logger.info "Into register_message_notification"
    Rails.logger.debug "Generate message id"
    #Generate safe message-id
    begin
        message_id = SecureRandom.urlsafe_base64
    end while MessageNotification.exists?(message_id: message_id)
    Rails.logger.debug "Message-id generated: #{message_id.inspect}"
    
    if campaign && source == 'campaign'
      Rails.logger.debug "Notification type: Campaign"
      #Create entry!
      merchant_store.message_notifications.create!( notification_type: 'campaign', recipient: recipient,
                                                    message_id: message_id, campaign_group_id: campaign.message_group_id, status_code_id: default_status_code.id,
                                                    merchant_store_id: merchant_store.id)
      
    elsif source == 'single'
      Rails.logger.debug "Notification type: Single"
      #Create entry!
      merchant_store.message_notifications.create!( notification_type: 'single', recipient: recipient,
                                                    message_id: message_id, status_code_id: default_status_code.id,
                                                    merchant_store_id: merchant_store.id) 
    else
      Rails.logger.debug "Notification type: Admin"
      MessageNotification.create!( notification_type: 'admin', recipient: recipient,
                                   message_id: message_id, status_code_id: default_status_code.id) 
    end
    return message_id
  end#End method

end#End class

#Invoked using delayed jobs. Can also be called in synched mode.
#Test:OK
class BackgroundWorker
  def processSignup(member, merchant_store, origin) 
    Rails.logger.info "Loading processSignup method"

    #Check if core attributes are present
    if member.present? && merchant_store.present? && !origin.blank?
      Rails.logger.debug "Member parameter: #{member.attributes.inspect}"
      Rails.logger.debug "Merchant-store parameter: #{merchant_store.attributes.inspect}"
      Rails.logger.debug "Origin parameter: #{origin.inspect}" 
      
      sign_up_status = false
      #Check if subscriber record already exists for specific merchant_store
      subscriber = merchant_store.subscribers.find_by_member_id(member.id)
      Rails.logger.debug "Checking is member is already subscribed..." 
      if subscriber.nil?
        Rails.logger.debug "Member is not subscribed. Proceeding with subscribe process..."
        #Create new subscriber record
        if subscriber = merchant_store.subscribers.create(member_id: member.id, start_date: Time.zone.now) 
          Rails.logger.debug "New subscriber record created successfully: #{subscriber.attributes.inspect}"
          sign_up_status = true 
        end
      elsif subscriber && origin == "store"
        Rails.logger.debug "Member is already subscriber. Sending notification sms about invalid signup..."
         #We only send sms for incorrect signups in stores - not on web since validation message is shown directly in interface
        result = SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( I18n.t(:already_signed_up, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone, merchant_store )
        Rails.logger.debug "Notification message sent successfully in SMS Gateway" if result 
      end

      if sign_up_status
        Rails.logger.debug "Proceeding to next step: Send welcome message (email, sms) to member, and present if eligble"
        #Check status for welcome offer for particular store
        welcome_offer = merchant_store.welcome_offer
        if subscriber.eligble_welcome_present? && welcome_offer.present? && welcome_offer.active
          Rails.logger.debug "Status 1: Subscriber is eligble for welcome present"
          Rails.logger.debug "Status 2: Welcome offer is active for merchant-store"
          Rails.logger.debug "Subscriber origin: #{origin.inspect}"
          Rails.logger.debug "Preparing to send either sms or email depending on origin: #{origin.inspect}"
          if origin == "store"
            Rails.logger.debug "Origin is store. Proceeding with sms notifications..."
            Rails.logger.debug "Sending SMS 1: Welcome message with comments about present to member"
            #Send welcome message with comments about welcome present 
            result = SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( I18n.t(:success_with_present, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone, merchant_store )
            if result
              Rails.logger.debug "SMS 1 sent successfully in SMS Gateway" 
            else
              Rails.logger.debug "Error: SMS 1 NOT sent due to unknown errors" 
            end
            result = nil
            Rails.logger.debug "Sending SMS 2: Message with welcome present"
            result = SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( welcome_offer.message, member.phone, merchant_store )
            if result
              Rails.logger.debug "SMS 2 sent successfully in SMS Gateway"
            else
              Rails.logger.debug "Error: SMS 2 NOT sent due to unknown errors" 
            end
          else
            Rails.logger.debug "Origin is web. Proceeding with email notifications..."
            Rails.logger.debug "Sending ONE e-mail with welcome message and present to member"
            #Send welcome e-mail with welcomepresent
            MemberMailer.delay.web_sign_up_present(member.id, merchant_store.id)
          end
        #Welcome notification (email, sms) without present
        else
          Rails.logger.debug "Subscriber NOT eligble for welcome present OR welcome offer not active for store"
          if origin == "store"
            Rails.logger.debug "Origin is store: #{origin.inspect}"
            Rails.logger.debug "Sending SMS message with welcome message without present"
            #Send normal welcome message without notes about welcome present
            result = SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( I18n.t(:success_without_present, store_name: merchant_store.store_name, city: merchant_store.city, :scope => [:business_messages, :store_signup]), member.phone, merchant_store )
            Rails.logger.debug "Welcome message sent successfully in SMS Gateway" if result 
          else
            Rails.logger.debug "Origin is web: #{origin.inspect}"
            Rails.logger.debug "Sending email with welcome message but no present"
            #Send welcome e-mail without welcomepresent
            MemberMailer.delay.web_sign_up(member.id, merchant_store.id)
          end
        end
      end
    else
       Rails.logger.debug "Error: Missing attributes in process_signup. Check if attributes are valid." 
       Rails.logger.fatal "Error: Missing attributes in process_signup. Check if attributes are valid." 
    end
  end#End process-signup

  #Vi skal overveje at lave et weblink til dette istedet i alle sms'er som sendes til medlemmet. Der skal måske oprettes en særskilt controller til dette.
  #Test:OK
  def stopStoreSubscription(sender, text)
    Rails.logger.info "Loading sms_handler stopStoreSubscription"

    #Determine if member already exists in database. First, incoming phone is standardized with +45 notation.
    converted_phone_number = SMSUtility::SMSFactory.convert_phone_number(sender)
    Rails.logger.debug "Converted phone number: #{converted_phone_number.inspect}"
    Rails.logger.debug "Trying to find existing member in database from phone number"
    member = Member.find_by_phone(converted_phone_number)
    if member.present?
      Rails.logger.debug "Member found in database: #{member.attributes.inspect}"   
      keyword = text.gsub('stop', '').gsub(/\s+/, "").downcase
      Rails.logger.debug "Keyword after downcase and remove whitespace: #{keyword.inspect}"
      
      Rails.logger.debug "Trying to find merchantstore in database from keyword"
      merchantStore = MerchantStore.find_by_sms_keyword(keyword)
      if merchantStore.present?
        Rails.logger.debug "Merchant-store found in database: #{merchantStore.attributes.inspect}"
        Rails.logger.debug "Trying to find subscriber record in database from keyword"
        subscriber = merchantStore.subscribers.find_by_member_id(member.id)
        if subscriber && subscriber.destroy 
          Rails.logger.debug "Subscriber record found. Proceeding with deletion of membership..."

          Rails.logger.debug "Subscriber record deleted. Sending message notification to user"
          if SMSUtility::SMSFactory.sendSingleAdminMessageInstant?( I18n.t(:success, store_name: merchantStore.store_name, :scope => [:business_messages, :opt_out] ), member.phone, merchantStore)
            Rails.logger.debug "Confirmation message sent to member about opt-out"
            Rails.logger.debug "Analyzing if member should be deleted too..in case of no subscribers and pure store-profile"
            if member.subscribers.empty? && !member.complete
              Rails.logger.debug "Member has no subscribers and is a pure store-only profile...go ahead and delete"
              if member.destroy
                Rails.logger.debug "Member deleted successfully"
              end
            end
          else
            Rails.logger.debug "Error when sending confirmation message sent to member about opt-out"
            Rails.logger.fatal "Error when sending confirmation message sent to member about opt-out"
          end
        else
          Rails.logger.debug "Subscriber not found. Could not destroy record."  
          Rails.logger.fatal "Subscriber not found. Could not destroy record."
        end
      else
        Rails.logger.debug "Merchant-store not found from received keyword"
        Rails.logger.fatal "Merchant-store not found from received keyword"
        #Log all keywords that doesn't match stores
        MessageError.create(recipient: sender, text: keyword, error_type: "invalid_keyword")
      end
    else
      Rails.logger.debug "Member NOT found from phone number"
      Rails.logger.fatal "Member NOT found from phone number" 
    end  
  end#end stopsubscription
  
  #Test:OK
  def signupMember(sender, text)
    Rails.logger.info "Loading sms_handler signupMember"
    keyword = text.gsub(/\s+/, "")
    Rails.logger.debug "Keyword parameter received...removed whitespaces: #{keyword.inspect}"
    Rails.logger.debug "Sender parameter received: #{sender.inspect}"
    
    #Determine if member already exists in database. First, incoming phone is standardized with +45 notation.
    converted_phone_number = SMSUtility::SMSFactory.convert_phone_number(sender)
    Rails.logger.debug "Converted phone number: #{converted_phone_number.inspect}"
    Rails.logger.debug "Trying to find existing member in database from phone number"
    member = Member.find_by_phone(converted_phone_number)     
    if member.nil?
      Rails.logger.debug "Member does NOT exist in database. New member is created"
      member = Member.new(phone: converted_phone_number, origin: 'store')
      member.validation_mode = 'store'
      if member.save
        Rails.logger.debug "New member saved successfully: #{member.attributes.inspect}"
      else
        Rails.logger.debug "Error when saving new member created in-store"
        Rails.logger.fatal "Error when saving new member created in-store" 
        return 
      end
    end

    if member.present?
      merchant_store = MerchantStore.active.find_by_sms_keyword(keyword)
      if merchant_store.present?
        Rails.logger.debug "Merchant-store found: #{merchant_store.attributes.inspect}"
        Rails.logger.debug "Calling processSignup method..."
        #Make call to base_controller method for detailed signup
        processSignup(member, merchant_store, "store")
      else
        Rails.logger.debug "Error: Merchant-store NOT found from received keyword"
        Rails.logger.fatal "Error: Merchant-store NOT found from received keyword"

        Rails.logger.fatal "Checking if member record should be deleted due to failure..."
        #Delete new member if sign-ups fails - only for pure store-profiles with no memberships
        if member.subscribers.empty? && !member.complete
          Rails.logger.debug "Member has no subscribers and is a pure store-only profile...go ahead and delete"
          if member.destroy
            Rails.logger.debug "Member deleted successfully"
          end
        end
        #Log all keywords that doesn't match stores
        message_error = MessageError.create!(recipient: sender, text: keyword, error_type: "invalid_keyword")
        Rails.logger.debug "Message error entry created: #{message_error.inspect}"
        #We don't respond to sms gateway with errors - for now - save money :-)
      end
    end
  end
end#end background worker class

end#end module

