#encoding: utf-8

class MyApi
  include HTTParty
  format :xml
end

namespace :campaign do
 
 desc "Retrieve campaign status from server"
  task :get_status => :environment do
  	#To-Do: Indsæt kode som skal kalde cimmobils service
  	campaigns = Campaign.all #Campaign.where(:activation_time => Time.now..(Time.now - 1.day))
    puts "Initializing campaign status batch job"
    
    puts "Loading status codes..."
    #Pre-load status codes
    status_codes = StatusCode.all

    status_codes_lookup = Hash.new

    #Initialize hash lookup to save sql queries
    status_codes.each do |code|
        status_codes_lookup[code.name] = code  
    end

    puts "Loading status codes...done"

    campaigns.each do |campaign|
        puts "Fetching data for #{campaign.title}"

        if campaign.message_group_id.present?
            puts "Campaign group-id is ok. Loading data..."
            puts campaign.message_group_id
        else
            puts "Invalid campaign group-id. Jumping to next record"
            next
        end

    	#https://gist.github.com/xentek/1756582 - link for this solution
        #http://blog.teamtreehouse.com/its-time-to-httparty
        #response = MyApi.get("http://sdk.ecmr.biz/src/GatewayXmlReport.aspx?rqGatewayID=#{ENV["SMS_GATEWAY_ID"]}&rqMessageGroupId=_Lizl-1_zfrVSnyqsJr3ZA" )
        puts "http://sdk.ecmr.biz/src/GatewayXmlReport.aspx?rqGatewayID=#{ENV["SMS_GATEWAY_ID"]}&rqMessageGroupId=#{campaign.message_group_id}"
        response = MyApi.get("http://sdk.ecmr.biz/src/GatewayXmlReport.aspx?rqGatewayID=#{ENV["SMS_GATEWAY_ID"]}&rqMessageGroupId=#{campaign.message_group_id}" )
        messages = response.parsed_response['Gateway']['Messages']

        if messages
            puts "Indenfor"
            #Retrieve all sms notifications for this campaign
    	   notifications = MessageNotification.where(campaign_group_id: campaign.message_group_id)
    	
    	   #Convert to hash for easy lookup - vi må prøve nogle metoder af.
    	   #http://stackoverflow.com/questions/4314384/ruby-on-rails-array-to-hash-with-key-array-of-values
    	   notifications_lookup = Hash.new

    	   #Initialize hash lookup to save sql queries
    	   notifications.each do |notification|
    	       notifications_lookup[notification.recipient] = notification	
    	   end

            #puts response.body.get('/messages/message') #, response.code, response.message, response.headers.inspect
            #puts response
    	   #Loop through each notification for a particular campaign
    	   #response.class.get("/messages/").each do |callback_message|
            #puts callback_message
            #puts "Found #{messages.length} messages for this campaign"
            messages.each do |item|
                status_code = item[1]['sStatus'].strip
                recipient = item[1]['sDeviceName'].strip
                message_id = item[1]['sProviderMessageId'].strip
            
                if status_code.present? && message_id.present? 
                    #notification =  MessageNotification.find_by_message_id(message_id)
                    notification = notifications_lookup[recipient]
                    if notification != nil && notification.status_code != "1"
                        if status_code == "0"
                            #Status-koder skal caches senere hen, da det generer for mange sql-kald.
                            notification.status_code = status_codes_lookup["0"]
                        elsif status_code == "1"
                            notification.status_code = status_codes_lookup["1"]
                        elsif status_code == "14"
                            notification.status_code = status_codes_lookup["14"]
                        elsif status_code == "129"
                            notification.status_code = status_codes_lookup["129"]
                        elsif status_code == "130"
                            notification.status_code = status_codes_lookup["130"]
                        else
                            #Default error
                            notification.status_code = status_codes_lookup["999"]
                        end
                        notification.save!
                    end
                end#if status-code present
            end#End looping through messages per campaign
        end#If messages
    end#End campaign
    puts "Finished fetching campaign updates"
  
  end#end task
end#End namespace


