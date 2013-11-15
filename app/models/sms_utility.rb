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

  TOTAL_MESSAGES_MONTH = 500

class SMSFactory

  #Primarily used by search functionality
  def self.convert_phone_number(phone_number)
    logger.info "Into convert_phone_number"
    logger.debug "Phone number: #{phone_number.inspect}"
    if validate_phone_number_converted?(phone_number)
      logger.debug "Phone number already valid. Returning..."
      return phone_number
    else
      logger.debug "Phone not valid. Need to convert"
      if phone_number.to_s.size > 8
        logger.debug "Phone length larger than 8 characters" 
        return phone_number = "+45" + phone_number.sub(/\A(0045|45)/, "").to_s.strip
      else
        logger.debug "Phone length is up to 8 characters"
        return phone_number = "+45" + phone_number.to_s.strip
      end
    end
  end

  def self.validate_sms?(message)
    logger.info "Into validate_sms?"
    #Reduceret udgave af http://stackoverflow.com/questions/15866068/regex-to-match-gsm-character-set
    #Testet med http://rubular.com
    #%r gør hele forskellen- dette skyldes at %r er beregnet til netop regulære udtryk
    result = message.match(SMSUtility::VALID_SMS_MESSAGE)
    logger.debug "Result: #{result.inspect}"
    return result
  end

  def self.validate_phone_number_converted?(phone_number)
    logger.info "Into validate_phone_number_converted?"
    result = phone_number.to_s.match(SMSUtility::VALID_PHONE_REGEX_STANDARD)
    logger.debug "Result: #{result.inspect}"
    return result
  end

  def self.validate_phone_number_incoming?(phone_number)
    logger.info "Into validate_phone_number_incoming?"
    result = phone_number.to_s.match(SMSUtility::VALID_PHONE_REGEX_INCOMING)
    logger.debug "Result: #{result.inspect}"
    return result
  end

  def self.validate_message_limits?(merchant_store, message_count)
    logger.info "Into validate_message_limits?"
    result = (merchant_store.message_notifications.month_total_messages.count + message_count) <= SMSUtility::TOTAL_MESSAGES_MONTH
    logger.debug "Result: #{result.inspect}"
    return result
  end

	#START SAVON
	#Afsendelse af sms til en enkelt person (typisk admin eller direkte kommunikation til et medlem)
  def self.sendSingleMessageInstant?(message, recipient, merchant_store)
    logger.info "Into sendSingleMessageInstant?"
    if validate_message_limits?(merchant_store, 1)
      logger.debug "Message limit not broken. Everything is OK, message can be sent"
      logger.debug "Message parameter: #{message.inspect}"
      logger.debug "Recipient parameter: #{recipient.inspect}"
      logger.debug "Merchant-store parameter: #{merchant_store.attributes.inspect}" if merchant_store
      messageContent = prepareMessage('InstantSingleMessage', nil, recipient, message, merchant_store) 
      logger.debug "Message payload prepared for gateway: #{messageContent.inspect}"
      #result = sendMessage?('push', messageContent) 
      #logger.debug "Message transmission result: #{result.inspect}" 
      return true 
    else
      #To-do: Throw error
    end
  end

  #Afsendelse af sms'er i forbindelse med tilmelding og afmelding m.v. Her er Club Novus provider
  def self.sendSingleAdminMessageInstant?(message, recipient, merchant_store)
    logger.info "Into sendSingleAdminMessageInstant?"

    logger.debug "Message parameter: #{message.inspect}"
    logger.debug "Recipient parameter: #{recipient.inspect}"
    logger.debug "Merchant-store parameter: #{merchant_store.attributes.inspect}" if merchant_store
    messageContent = prepareMessage('InstantSingleAdminMessage', nil, recipient, message, merchant_store) 
    logger.debug "Message payload prepared for gateway: #{messageContent.inspect}"   
    #result = sendMessage?('push', messageContent)  
    #logger.debug "Message transmission result: #{result.inspect}" 
    return true 
  end

  #Kampagne metoder
  def self.sendOfferReminderScheduled?(campaign, merchant_store)
    logger.info "Into sendOfferReminderScheduled?"
    if validate_message_limits?(merchant_store, campaign.campaign_members.count)
      logger.debug "Message limit not broken. Everything is OK, campaign can be scheduled"
      logger.debug "Campaign parameter: #{campaign.attributes.inspect}"
      logger.debug "Merchant-store parameter: #{merchant_store.attributes.inspect}" if merchant_store
      messageContent = prepareMessage('CreateCampaignScheduled', campaign, nil, nil, merchant_store)
      logger.debug "Campaign payload prepared for gateway: #{messageContent.inspect}"
      #result = sendMessage?('push_scheduled', messageContent) 
      #logger.debug "Message transmission result: #{result.inspect}"
      return true
    end
  end

  def self.reschduleOfferReminder?(campaign)
    logger.info "Into reschduleOfferReminder?"
    logger.debug "Campaign parameter: #{campaign.attributes.inspect}"
    messageContent = prepareMessage('RescheduleCampaign', campaign, nil, nil, nil)
    logger.debug "Campaign reschedule payload prepared for gateway: #{messageContent.inspect}"
    #result = sendMessage?('reschedule_group', messageContent) 
    #logger.debug "Message transmission result: #{result.inspect}"
    return true
      
  end

  def self.cancelScheduledOfferReminder?(campaign)
    logger.info "Into cancelScheduledOfferReminder?"
    logger.debug "Campaign parameter: #{campaign.attributes.inspect}"
    messageContent = prepareMessage('CancelCampaign', campaign, nil, nil, nil)
    logger.debug "Campaign cancel payload prepared for gateway: #{messageContent.inspect}"
    #result = sendMessage?('cancel_group', messageContent)
    #logger.debug "Message transmission result: #{result.inspect}"
    return true
  end  

  private

  def self.prepareMessage(mode, campaign, recipient, message, merchant_store)
    logger.info "Into prepareMessage"
    logger.debug "Running mode: #{mode.inspect}"
    
    xml_body = ""
    default_status_code = StatusCode.find_by_name("500")
    logger.debug "Default status code lookup: #{default_status_code.attributes.inspect}" if default_status_code.present?
    
    if mode == 'CreateCampaignScheduled'
      recipientString = ""

      #Insert placeholder macro for stop-link
      message = campaign.message + "%StopLink%"
      campaign.campaign_members.each do |campaign_member|
        #Generate safe message-id from log method
        recipient = campaign_member.subscriber.member.phone
        message_id = register_message_notification(campaign, recipient, merchant_store, default_status_code, "campaign")
        recipientString += "<to id='#{message_id}' StopLink='#{campaign_member.subscriber.opt_out_link_sms}' >" + recipient + "</to>" 
      end
      recipientXml = "<recipients>" + recipientString + "</recipients>"     
      stringXml = "<bulk>" +    
      "<message>" + HTMLEntities.new.encode(message) + "</message>" +
      "<header><from>Club-Novus</from>" +
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
      "<from>Club-Novus</from>" +
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
    logger.info "Into sendMessage?"
    #wsdl_file = "http://sdk.ecmr.biz/src/gateway.asmx?wsdl"  
    wsdl_file = File.read(Rails.root.join("config/wsdl/CIMMobil_ssl.xml"))
    #wsdl_file = "http://127.0.0.1:8088/mockGatewaySoap12?wsdl"
    #wsdl_file =

    client = Savon.client(  env_namespace: :soap, wsdl: wsdl_file, raise_errors: true, ssl_verify_mode: :none, 
                  pretty_print_xml: true, namespaces: { "xmlns:myb" => "http://myblipz.com" },
                  soap_version:2, soap_header: %{<myb:AuthHeader><myb:Login>#{ENV["SMS_GATEWAY_USER_NAME"]}</myb:Login><myb:Password>#{ENV["SMS_GATEWAY_PASSWORD"]}</myb:Password></myb:AuthHeader>})
    result = client.call(method.to_sym, message: messageContent )
    logger.debug "Transmission result: #{result.inspect}" 
    return result  
  end
  #END SAVON

  #This method is invoked once for each recipient in campaign or for single message.
  def self.register_message_notification(campaign, recipient, merchant_store, default_status_code, source)
    logger.info "Into register_message_notification"
    #Generate safe message-id
    begin
        message_id = SecureRandom.urlsafe_base64
    end while MessageNotification.exists?(message_id: message_id)
    logger.debug "Message-id: #{message_id.inspect}"
    
    if campaign && source == 'campaign'
      logger.debug "Notification type: Campaign"
      #Create entry!
      merchant_store.message_notifications.create!( notification_type: 'campaign', recipient: recipient,
                                                    message_id: message_id, campaign_group_id: campaign.message_group_id, status_code_id: default_status_code.id,
                                                    merchant_store_id: merchant_store.id)
      
    elsif source == 'single'
      logger.debug "Notification type: Single"
      #Create entry!
      merchant_store.message_notifications.create!( notification_type: 'single', recipient: recipient,
                                                    message_id: message_id, status_code_id: default_status_code.id,
                                                    merchant_store_id: merchant_store.id) 
    else
      logger.debug "Notification type: Admin"
      merchant_store.message_notifications.create!( notification_type: 'admin', recipient: recipient,
                                                    message_id: message_id, status_code_id: default_status_code.id) 
    end
    return message_id
  end#End method

end#End class

end#end module

