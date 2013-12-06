#encoding: utf-8

class MyApi
  include HTTParty
  format :xml
end

namespace :campaign do
  
  #Step 1: Confirm campaigns in SMS gateway
  desc "Confirm due campaigns with sms gateway..."
  #Interval: Every 10 minutes
  task :confirm_campaign => :environment do
    puts "Preparing to confirm campaigns due for activation during the next +10 => 20 minutes"
    campaigns = Campaign.where(:activation_time => (Time.zone.now + 10.minutes)..(Time.zone.now + 20.minutes ) ).scheduled
    puts "Number of campaigns to be processed in this time window: #{campaigns.size.inspect}"
    
    campaigns.each do |campaign|
        error = false
        merchant_store = MerchantStore.find_by_id(campaign.merchant_store_id)
        if merchant_store.present?
            result = SMSUtility::SMSFactory.sendOfferReminderScheduled?(campaign, merchant_store)
            unless result && campaign.update_column(:status, 'gateway_confirmed')
                error = true
            end
        else
            error = true
        end
        if error
            campaign.update_column(:status, 'error')   
        end
    end
    puts "Done confirming campaigns"
  end#End task
 
  #Step 2: Retrieve group campaig status
  desc "Retrieve campaign status from server"
  #Interval: Every 60 minutes
  task :get_status => :environment do
    #Find all confirmed campaigns with activation_time in the past up until 30 minutes ago.
    campaigns = Campaign.where(:activation_time => (Time.zone.now - 20.hours)..(Time.zone.now - 30.minutes) ).where(:status => 'gateway_confirmed')
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
           puts "Loaded status messages from SMS gateway. Starting to process..."
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
                #Need to put content into new clean hash - to avoid weird bugs
                tmp = item[1]
                puts "Item-hash" + tmp.to_s
                status_code = tmp['sStatus']
                recipient =  tmp['sDeviceName']
                message_id = tmp['sProviderMessageId']
                puts "Status-kode: " + status_code
                puts "Recipient: " + recipient
                puts "Message-id: " + message_id
            
                if status_code.present? && recipient.present? && message_id.present? 
                    #Remove whitespaces from non-blank string values
                    status_code = status_code.strip
                    recipient = recipient.strip
                    message_id = message_id.strip    

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
        #campaign.status = 'status_retrived_once'
        #campaign.save(validate: false)
        campaign.update_column(:status, 'status_retrived_once')
    end#End campaign
    puts "Finished fetching campaign updates"
  end#end task

  #Step 3: Update campaign members
  desc "Retrieve campaign status from server"
  #Interval: Every 60 minutes
  task :update_member_status => :environment do
    campaigns = Campaign.where(:activation_time => (Time.zone.now - 10.hours)..(Time.zone.now - 30.minutes)).where(:status => 'status_retrived_once')
    puts "#{campaigns.size} campaigns with status retrieved from gateway loaded...done"
    puts "Preparing to update campaign member_status"
    
    campaigns.each do |campaign|
        notifications = MessageNotification.where(campaign_group_id: campaign.message_group_id)

        notifications.each do |notification|
            member = Member.find_by_phone(notification.recipient)
            if member #code 1
                campaign_member = campaign.campaign_members.find_by_subscriber_id(member)
                if campaign_member
                    if notification.status_code.name == '1'
                        campaign_member.status = 'received' 
                    else
                        campaign_member.status = 'not-received'
                    end 
                    campaign_member.save
                end 
            end
        end#Finish notification logic for campaign

        #campaign.status = 'completed'
        campaign.update_column(:status, 'completed')
        merchant_store = MerchantStore.find(campaign.merchant_store_id)
        if merchant_store
            merchant_store.event_histories.create(event_type: "campaign-finished", description: "Kampagnen #{campaign.title} er nu afsluttet")
        end
    end#Finish campaign logic
    puts "Finished updating campaign member status for #{campaigns.size}"
  end#End task

  #Step 4: Delete status messages related to campaign with error status - due to billing issues
  desc "Batch delete error message notifications to avoid billing issues"
  #Interval: Once every night
  task :delete_error_status => :environment do
    campaigns = Campaign.where(:activation_time => (Time.zone.now - 2.day)..(Time.zone.now - 1.day)).where(:status => 'error')
    puts "Preparing to delete error entries from MessageNotification..."
    puts "#{campaigns.size} campaigns with related status messages due for deletion"
    campaigns.each do |campaign|
        notifications = MessageNotification.where(campaign_group_id: campaign.message_group_id)
        if notifications.size != 0
            notifications.delete_all
        end
    end#Finish campaign logic
    puts "Finished deleting invalid error entries in MessageNotification"
  end#End task
  
end#End namespace


