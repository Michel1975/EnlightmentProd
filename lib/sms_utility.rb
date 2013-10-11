module SMSUtility
class SMSFactory

	#START SAVON
	#Afsendelse af sms til en enkelt (typisk admin eller direkte kommunikation til et medlem)
  def self.sendSingleMessageInstant?(message, recipient)
    messageContent = prepareMessage('InstantSingleMessage', nil, Array.new << Member.new(phone: recipient), message)    
    sendMessage?('push', messageContent)   
  end
  
  #Kampagne metoder
  def self.sendOfferReminderScheduled?(campaign, recipients)
    messageContent = prepareMessage('CreateCampaignScheduled', campaign, nil, nil)
    
    sendMessage?('push_scheduled', messageContent) 
    
    #Step 1: To-Do - Lav opslag i grupper via join objektet
    #Step X: Opdater besked-status, når webservicen har accepteret ordren
  end

  def self.reschduleOfferReminder?(campaign)
    messageContent = prepareMessage('RescheduleCampaign', campaign, nil, nil)
    
    sendMessage?('reschedule_group', messageContent) 
      
  end

  def self.cancelScheduledOfferReminder?(campaign)
    messageContent = prepareMessage('CancelCampaign', campaign, nil, nil)

    sendMessage?('cancel_group', messageContent)
  end  

  def prepareMessage(mode, campaign, recipients, adminMessage)
    xml_body = ""
    if mode == 'CreateCampaignScheduled'
      recipientString = ""
      #status_code = StatusCode.find_by_name("500")
      @campaign.campaign_members.each do |campaign_member|
        recipientString += "<to>" + recipient.phone + "</to>" 
        #MessageNotification.create(recipient: recipient.phone, message_group_id: @campaign.message_group_id, type: 'campaign', status_code: status_code)
      end
      recipientXml = "<recipients>" + recipientString + "</recipients>"     
      stringXml = "<bulk>" +    
      "<message>" + HTMLEntities.new.encode(@campaign.message) + "</message>" +
      "<header><from>Club Novus</from>" +
      "<GroupID>" + @campaign.message_group_id + "</GroupID></header>" + 
      recipientXml + "</bulk>"      
      builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
      builder.tag!("myb:iGatewayId", ENV["SMS_GATEWAY_ID"])
      builder.tag!("myb:sAlertXml", stringXml)
      builder.tag!("myb:sDateTimeToSend",  @campaign.activation_time.strftime("%Y-%m-%dT%H:%M:%S")) 
      builder.tag!("myb:timeZone", 'Denmark')
  elsif mode == 'CancelCampaign'    
    builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
    builder.tag!("myb:iGatewayId", ENV["SMS_GATEWAY_ID"])
    builder.tag!("myb:sMessageGroupId", @campaign.message_group_id)
  elsif mode == 'RescheduleCampaign'
    builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
    builder.tag!("myb:iGatewayId", ENV["SMS_GATEWAY_ID"])
    builder.tag!("myb:sMessageGroupId",  @campaign.message_group_id)
    #to-do: builder.tag!("myb:sMerchantId", )
    builder.tag!("myb:sDateTimeToSend", @campaign.activation_time.strftime("%Y-%m-%dT%H:%M:%S") ) 
    builder.tag!("myb:timeZone", 'Denmark') 
  elsif mode == 'InstantSingleMessage'     
    message_id = SecureRandom.urlsafe_base64
    stringXml = "<xml><item>" +    
      "<message>" + HTMLEntities.new.encode(adminMessage) + "</message>" +
      "<messageid>" + message_id + "</messageid>" +
      "<recipient>" + recipients.first.phone + "</recipient>" +  
      "</item></xml>"      
      builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
      builder.tag!("myb:iGatewayId", ENV["SMS_GATEWAY_ID"])
      #to-do: builder.tag!("myb:sMerchantId", )      
      builder.tag!("myb:sAlertXml", stringXml)      
      #Message_status.create(messageid: message_id, message_type: 'SMS', recipient: recipient.phone) 
  end
  return xml_body 
end
  def sendMessage?(method, messageContent)
  #wsdl_file = "http://sdk.ecmr.biz/src/gateway.asmx?wsdl"  
  wsdl_file = File.read(Rails.root.join("config/wdsl/CIMMobil_ssl.xml"))
  #wsdl_file = "http://localhost:8088/mockGatewaySoap12?wsdl"
  #wsdl_file =

  client = Savon.client(  env_namespace: :soap, wsdl: wsdl_file, raise_errors: true, ssl_verify_mode: :none, 
                pretty_print_xml: true, namespaces: { "xmlns:myb" => "http://myblipz.com" },
                soap_version:2, soap_header: %{<myb:AuthHeader><myb:Login>sdk@disruptx.dk</myb:Login><myb:Password></myb:Password>fre_3rG443</myb:AuthHeader>})
  result = client.call(method.to_sym, message: messageContent )   
  end
  #END SAVON

end#End class

end#end module

