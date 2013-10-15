#encoding: utf-8
namespace :campaign do
  #include HTTParty
 
 desc "Retrieve campaign status from server"
  task :get_status => :environment do
  	#To-Do: Indsæt kode som skal kalde cimmobils service
  	campaigns = Campaign.where(:activation_time => Time.now..(Time.now - 1.day))

    campaigns.each do |campaign|
    	#response = HTTParty.get('http://cim_url#{campaign.message_group_id}')
    	response = ""
    	#Retrieve all sms notifications for this campaign
    	notifications = MessageNotification.find_by_message_id(campaign.message_id)
    	
    	#Convert to hash for easy lookup - vi må prøve nogle metoder af.
    	#http://stackoverflow.com/questions/4314384/ruby-on-rails-array-to-hash-with-key-array-of-values
    	notifications_lookup = Hash.new

    	#Initialize hash lookup to save sql queries
    	notifications.each do |notification|
    		notifications_lookup[notification.id] = notification	
    	end

    	#Loop through each notification for a particular campaign
    	response.each do |status|
    		notification = notifications_lookup[status.recipient]
    		if notification != nil
    			if status.status_code == "0"
    				#Skal også optimeres senere hen fordi det generer for mange sql-kald
    				notification.status_code = StatusCode.find_by_name("0")
    			elsif status.status_code == "1"
    				notification.status_code = StatusCode.find_by_name("1")	
    			elsif status.status_code == "14"
    				notification.status_code = StatusCode.find_by_name("14")
    			elsif status.status_code == "129"
    				notification.status_code = StatusCode.find_by_name("129")
    			elsif status.status_code == "130"
    				notification.status_code = StatusCode.find_by_name("129")
    			else
    				#Default error
    				notification.status_code = StatusCode.find_by_name("999")
    			end
    			notification.save!
    		end
    	end
    end
  	

  end#end task

end#End namespace


