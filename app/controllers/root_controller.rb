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
		#Note: Vi bliver nødt til at lave vores egen sidebar med markers. Vi skal bare finde linket til hver kort.
		#link til kort markør: http://stackoverflow.com/questions/8608602/make-map-marker-direct-link-onclick-for-gmaps4rails
		@merchant_stores = MerchantStore.all 
		@json = @merchant_stores.to_gmaps4rails do |merchant, marker|
			member_status = !member_ships.empty? && member_ships.has_key?(merchant.id)
  			marker.infowindow render_to_string(:partial => "info", :locals => { :merchant => merchant, status: member_status} )
  			if member_status
  				marker.picture({
                  :picture => ActionController::Base.helpers.asset_path("map_signed_up.png"),
                  :width   => 32,
                  :height  => 32
                 })	
  			else
  				marker.picture({
                  :picture => ActionController::Base.helpers.asset_path("map_not_signed_up.png"),
                  :width   => 32,
                  :height  => 32
                 })		
  			end
  			marker.title merchant.store_name
  			marker.sidebar merchant.store_name + ", " + merchant.map_address
  			marker.json({ :merchant_id => merchant.id})
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
    if @merchant_store.subscribers.find_by_member_id(@member.id).nil?
		  @merchant_store.subscribers.create!(member_id: @member.id, start_date: Date.today)
    end
    #else
      #render :nothing => true
		#
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js  
    end
  end

  def unsubscribe
    @subscriber = Subscriber.find_by_member_id(params[:id])
    if @subscriber.present?
      @merchant_store = MerchantStore.find(@subscriber.merchant_store_id)
      @merchant_store.subscribers.find(@subscriber.id).destroy
    end
    #else
      #render :nothing => true
    #redirect_to root_path
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js  
    end
  end

    def favorites
    	@member_user = current_member_user
    	@favorite_stores = @member_user.subscribers.paginate(page: params[:page], :per_page => 20)  
    end
end


