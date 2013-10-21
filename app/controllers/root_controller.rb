class RootController < ApplicationController
	#default layout application is used
	skip_before_filter :require_login, :only => [:home, :show_merchant_store, :stop_sms_subscription_view, :stop_sms_subscription_update]

	
  def home
		member_ships = Hash.new
		if current_member_user && current_member_user.subscribers.any?
			current_member_user.subscribers.each do |c|
  				if c.active
            member_ships[c.merchant_store_id] = c.id
          end
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
      subscriber = current_member_user && @merchant_store.subscribers.find_by_member_id(current_member_user.id)
    	@subscribed = subscriber && subscriber.active ? true : false
	end

	
  #Via map
  def subscribe
		@member = Member.find(params[:subscriber][:member_id])
		@merchant_store = MerchantStore.find(params[:subscriber][:merchant_store_id])
    subscriber = @merchant_store.subscribers.find_by_member_id(@member.id)
    if subscriber.nil? || !subscriber.active
      processSignup(@member, subscriber, @merchant_store, "web")
    end
    #else
      #render :nothing => true
		#
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js  
    end
  end

  #Via map
  def unsubscribe
    @subscriber = Subscriber.find_by_member_id(params[:id])
    @merchant_store = MerchantStore.find(@subscriber.merchant_store_id)
    if @subscriber.present? && @subscriber.active && @merchant_store
      @subscriber.opt_out
      @subscriber.save!
      #Send opt-out e-mail to member
      MemberMailer.web_opt_out(@subscriber.member, @merchant_store).deliver
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

  #Sms functionality
  def stop_sms_subscription_view
    @token = params[:token]
    @member = Member.find(params[:member_id])
    @merchant_store = MerchantStore.find(params[:merchant_id])
    if @token.present? && @member.present? && @merchant_store.present?
      render 'stop_sms'
    else
      #Eller en 404-fejl med fejlbesked
      redirect_to root_path
    end   
  end

  def stop_sms_subscription_update
    @token = params[:token]
    @member = Member.find(params[:member_id])
    @merchant_store = MerchantStore.find(params[:merchant_store_id])  
    if @token == @member.access_key
      subscriber = @merchant_store.subscribers.find_by_member_id(@member.id)
      if subscriber
        subscriber.opt_out
        if subscriber.save!
          #Send opt-out e-mail to member
          MemberMailer.web_opt_out(@member, @merchant_store).deliver
          flash[:success] = t(:opt_out, store_name: @merchant_store.store_name, :scope => [:business_messages, :web_profile])
          render 'stop_sms'
        end
      else
        flash[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
        render 'stop_sms'
      end
    else
      flash[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
      render 'stop_sms'
    end  
  end 

end#End class




