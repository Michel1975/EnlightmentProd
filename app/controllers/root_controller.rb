class RootController < ApplicationController
	#default layout application is used
	skip_before_filter :require_login, :only => [:home]

	def home
		member_ships = Hash.new
		if current_member_user && current_member_user.subscribers.any?
			current_member_user.subscribers.each do |c|
  				member_ships[c.merchant_store_id] = c.id
  			end
		end	
		#http://jsfiddle.net/jEhJ3/597/
		#http://t3923.codeinpro.us/q/51502208e8432c04261eb26e
		@json = MerchantStore.all.to_gmaps4rails do |merchant, marker|
			member_status = !member_ships.empty? && member_ships.has_key?(merchant.id)
  			marker.infowindow render_to_string(:partial => "info", :locals => { :merchant => merchant, status: member_status} )
  			if member_status
  				marker.picture({
                  :picture => "http://maps.google.com/mapfiles/ms/icons/green-dot.png",
                  :width   => 32,
                  :height  => 32
                 })	
  			else
  				marker.picture({
                  :picture => "http://maps.google.com/mapfiles/ms/icons/blue-dot.png",
                  :width   => 32,
                  :height  => 32
                 })		
  			end
  			marker.title merchant.store_name
  			marker.sidebar merchant.store_name
  			marker.json({ :id => merchant.id})
		end
	end

	def secret
	end

	def show_merchant_store
    	@merchant_store = MerchantStore.find(params[:id])
    	@subscribed = current_member_user && @merchant_store.subscribers.find_by_member_id(current_member_user.id)
	end

	def subscribe
		@member = Member.find(params[:subscriber][:member_id])
		@merchant_store = MerchantStore.find(params[:subscriber][:merchant_store_id])
		@merchant_store.subscribers.create!(member_id: @member.id, start_date: Date.today)
      	redirect_to root_path
    end

    def unsubscribe
    	@subscriber = Subscriber.find_by_member_id(params[:id])
    	@merchant_store = MerchantStore.find(@subscriber.merchant_store_id)
    	@merchant_store.subscribers.find(@subscriber.id).destroy
    	redirect_to root_path
    end

    
end


