class ApplicationController < ActionController::Base
	before_filter :require_login

  def default_url_options
    {:locale => I18n.locale}
  end

  require 'builder'  
  protect_from_forgery
	require 'will_paginate/array'#https://github.com/mislav/will_paginate/issues/163
  
  #include Shared::SessionsHelper
  include ApplicationHelper
  
  def merchant_user
      redirect_to root_path unless current_user.sub_type == 'MerchantUser'
  end

  def member_user
      redirect_to root_path unless current_user.sub_type == 'Member'
  end

  def not_authenticated
    redirect_to root_path, :alert => t(:not_authenticated, :scope => [:business_validations, :generic])
    #if current_user.sub_type == "MerchantUser"
  	   #redirect_to shared_login_merchant_url, :alert => "First login to access this page."
    #elsif current_user.sub_type == "Member"
       #redirect_to shared_login_member_url, :alert => "First login to access this page."  
    #end
  end

  helper_method :current_users_list
  #def determine_layout
    #current_merchant_store.nil? ? "application" : "merchant"
  #end

  def update_eventhistory(event_type, description)
    if(event_type && description)
      current_merchant_store.event_histories.create(event_type: event_type, description: description)
    end
  end

#START SAVON
#Afsendelse af sms til en enkelt (typisk admin eller direkte kommunikation til et medlem)
  def sendSingleMessageInstant?(message, recipient)
    messageContent = prepareMessage('InstantSingleMessage', nil, Array.new << Member.new(phone: recipient), message)    
    sendMessage?('push', messageContent)   
  end
  
  #Kampagne metoder
  def sendOfferReminderScheduled?(promotion_plan, recipients)
    messageContent = prepareMessage('CreateCampaignScheduled', promotion_plan, recipients, nil)
    
    sendMessage?('push_scheduled', messageContent) 
    
    #Step 1: To-Do - Lav opslag i grupper via join objektet
    #Step X: Opdater besked-status, når webservicen har accepteret ordren
  end

  def sendOfferReminderInstant?(promotion_plan, recipients)
    #Conduct database queries with the selected group(s)
    #put this into an array recipients fra member-tabellen
    messageContent = prepareMessage('CreateCampaignInstant', promotion_plan, recipients, nil)
    
    sendMessage?('push', messageContent)      
  end

  def reschduleOfferReminder?(promotion_plan)
    messageContent = prepareMessage('RescheduleCampaign', promotion_plan, nil, nil)
    
    sendMessage?('reschedule_group', messageContent) 
      
  end

  def cancelScheduledOfferReminder?(promotion_plan)
    messageContent = prepareMessage('CancelCampaign', promotion_plan, nil, nil)

    sendMessage?('cancel_group', messageContent)
  end  

  def prepareMessage(mode, promotion_plan, recipients, adminMessage)
    xml_body = ""
    if mode == 'CreateCampaignInstant' || mode == 'CreateCampaignScheduled'
      recipientString = ""
      message_group = SecureRandom.urlsafe_base64
      @promotion_plan.message_group = message_group     
      recipients.each do |recipient|
        message_id = SecureRandom.urlsafe_base64        
        recipientString += "<to id='#{message_id}'>" + recipient.phone + "</to>" 
        @promotion_plan.message_statuses.create(messageid: message_id, message_type: 'SMS', recipient: recipient.phone)             
      end
      recipientXml = "<recipients>" + recipientString + "</recipients>"     
      stringXml = "<bulk>" +    
      "<message>" + HTMLEntities.new.encode(promotion_plan.message) + "</message>" +
      "<header><from>Club Novus</from>" +
      "<GroupID>" + message_group + "</GroupID></header>" + 
      recipientXml + "</bulk>"      
      builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
      builder.tag!("myb:iGatewayId", "20894")
      builder.tag!("myb:sAlertXml", stringXml)
      if mode == 'CreateCampaignScheduled'
        builder.tag!("myb:sDateTimeToSend",  @promotion_plan.delivery.strftime("%Y-%m-%dT%H:%M:%S")) 
        builder.tag!("myb:timeZone", 'Denmark')
      end
  elsif mode == 'CancelCampaign'    
    builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
    builder.tag!("myb:iGatewayId", "20894")
    builder.tag!("myb:sMessageGroupId",  @promotion_plan.message_group)
  elsif mode == 'RescheduleCampaign'
    builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
    builder.tag!("myb:iGatewayId", "20894")
    builder.tag!("myb:sMessageGroupId",  @promotion_plan.message_group)
    #to-do: builder.tag!("myb:sMerchantId", )
    builder.tag!("myb:sDateTimeToSend",  @promotion_plan.delivery.strftime("%Y-%m-%dT%H:%M:%S") ) 
    builder.tag!("myb:timeZone", 'Denmark') 
  elsif mode == 'InstantSingleMessage'     
    message_id = SecureRandom.urlsafe_base64
    stringXml = "<xml><item>" +    
      "<message>" + HTMLEntities.new.encode(adminMessage) + "</message>" +
      "<messageid>" + message_id + "</messageid>" +
      "<recipient>" + recipients.first.phone + "</recipient>" +  
      "</item></xml>"      
      builder = Builder::XmlMarkup.new(:target => xml_body, :indent => 2)
      builder.tag!("myb:iGatewayId", "20894")
      #to-do: builder.tag!("myb:sMerchantId", )      
      builder.tag!("myb:sAlertXml", stringXml)      
      #Message_status.create(messageid: message_id, message_type: 'SMS', recipient: recipient.phone) 
  end
  return xml_body 
end
  def sendMessage?(method, messageContent)
  #wsdl_file = "http://sdk.ecmr.biz/src/gateway.asmx?wsdl"  
  #wsdl_file = File.read(Rails.root.join("config/wdsl/CIMMobil_ssl.xml"))
  #wsdl_file = "http://localhost:8088/mockGatewaySoap12?wsdl"
  wsdl_file = nil

  client = Savon.client(  env_namespace: :soap, wsdl: wsdl_file, raise_errors: true, ssl_verify_mode: :none, 
                pretty_print_xml: true, namespaces: { "xmlns:myb" => "http://myblipz.com" },
                soap_version:2, soap_header: %{<myb:AuthHeader><myb:Login>"#{ENV["SMS_GATEWAY_USER_NAME"]}"</myb:Login><myb:Password>"#{ENV["SMS_GATEWAY_PASSWORD"]}"</myb:Password></myb:AuthHeader>})
  result = client.call(method.to_sym, message: messageContent )   
  end
  #END SAVON

  protected
    def current_users_list
      current_users.map {|u| u.username}.join(", ")
    end

	
end#end class
