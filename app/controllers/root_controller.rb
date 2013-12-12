#encoding: utf-8
class RootController < ApplicationController
	#Default 'Application' layout application is used
	skip_before_filter :require_login, :only => [:home, :merchant_info, :search_stores, :contact, :show_merchant_store, :stop_sms_subscription_view, :stop_sms_subscription_update]
	skip_before_filter :authorize

  #Test:OK
  def merchant_info 
    logger.info "Loading Root merchant_info action"  
  end

  #Test:OK
  def contact
    logger.info "Loading Root contact action"   
  end
  
  #Test:OK
  def home
    logger.info "Loading Root home action"
		#http://jsfiddle.net/jEhJ3/597/
		#http://t3923.codeinpro.us/q/51502208e8432c04261eb26e
		#Note: Vi bliver nødt til at lave vores egen sidebar med markers. Vi skal bare finde linket til hver kort.
		#link til kort markør: http://stackoverflow.com/questions/8608602/make-map-marker-direct-link-onclick-for-gmaps4rails
		logger.debug "Resetting search params if they exist...."
    params[:city].delete if params[:city]
    params[:store_name].delete if params[:store_name]
    

    @merchant_stores = MerchantStore.search('Frederiksværk', "")
    @search = false
    logger.debug "Merchant-stores attributes hash: #{@merchant_stores.inspect}"
    logger.debug "Loading Google Maps markers..."
    @json = showMarkers(@merchant_stores)
	end

  #Test:OK
  def search_stores
    logger.info "Loading Root search_stores action"
    @search = true
    @city = params[:city]
    logger.debug "Search parameter - city: #{@city.inspect}"
    @store_name = params[:store_name]
    logger.debug "Search parameter - store_name: #{@store_name.inspect}"
    @search_result = MerchantStore.search(@city, @store_name ).page( params[:page] ).per_page(15)
    logger.debug "Search result: #{@search_result.inspect}"
    if @search_result.empty?
      logger.debug "Search result = No stores found"
      logger.debug "Loading default map view"
      #We need to display something on map - reset to base city
      @city = 'Frederiksværk' 
      @merchant_stores = MerchantStore.search(@city, "")
      @json = showMarkers(@merchant_stores)
    else
      #Extra assignment to MerchantStore variable
      @merchant_stores = @search_result
      logger.debug "Loading Google Maps markers..."
      @json = showMarkers(@search_result)
    end
    render 'home'
  end

  #Test:OK
	def show_merchant_store
    logger.info "Loading Root show_merchant_store action"
    @merchant_store = MerchantStore.find_by_id(params[:id])
    if @merchant_store.present? && @merchant_store.active? 
      logger.debug "Merchant-store - attributes hash: #{@merchant_store.attributes.inspect}"
      @subscriber = member_user? && @merchant_store.subscribers.find_by_member_id(current_member_user.id)
      logger.debug "Subscriber: #{@subscriber.inspect}"
      @subscribed = @subscriber.present? ? true : false
      logger.debug "Subscribed?: #{@subscribed.inspect}"
    else
      logger.debug "Error: Missing attributes for showing unsubscribe form"
      logger.fatal "Error: Missing attributes for showing unsubscribe form"
      flash[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
      redirect_to root_path  
    end
	end
  
  #SMS: Invoked from Bit.ly links in sms - provided dynamic stop links are used.
  #Test:OK
  def stop_sms_subscription_view
    logger.info "Loading Root stop_sms_subscription_view action"
    @token = params[:token]
    logger.debug "Token parameter: #{@token.inspect}" if @token.present?
    
    @member = Member.find_by_id(params[:member_id])
    logger.debug "Member: #{@member.attributes.inspect}" if @member.present?
    
    @merchant_store = MerchantStore.find_by_id(params[:merchant_id])
    logger.debug "Merchant-store: #{@merchant_store.attributes.inspect}" if @merchant_store.present?
    
    if @token.present? && @member.present? && @merchant_store.present?
      logger.debug "All required attributes present. Displaying unsubscribe form..."
      render 'stop_sms'
    else
      logger.debug "Error: Missing attributes for showing unsubscribe form"
      logger.fatal "Error: Missing attributes for showing unsubscribe form"
      flash[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
      redirect_to root_path
    end
  end

  #SMS:Confirm and save opt-out from bit.ly link in sms
  #Test:OK
  def stop_sms_subscription_update
    logger.info "Loading Root stop_sms_subscription_update action"
    @token = params[:token]
    logger.debug "Token: #{@token.inspect}" if @token.present?
    @member = Member.find_by_id(params[:member_id])
    logger.debug "Member: #{@member.attributes.inspect}" if @member.present?
    @merchant_store = MerchantStore.find_by_id(params[:merchant_store_id])
    logger.debug "Merchant-store: #{@merchant_store.attributes.inspect}" if @merchant_store.present?

    if @token.present? && @member.present? && @merchant_store.present?
      logger.debug "All attributes are present..proceeding with unsubscribing"
      if @token == @member.access_key
        logger.debug "Token equals access key on member. Continue unsubscribe process..."
        logger.debug "Trying to lookup subscriber"
        subscriber = @merchant_store.subscribers.find_by_member_id(@member.id)
        if subscriber.present?
          logger.debug "Subscriber found in database: #{subscriber.attributes.inspect}"
          if subscriber.destroy
            logger.debug "Subscriber unsubscribed successfully"
            
            #Send opt-out e-mail to member if complete member
            if @member.complete
              logger.debug "Member has a complete web profile, thus we send a delayed notification email" 
              MemberMailer.delay.web_opt_out(@member, @merchant_store)
              logger.debug "Email sent successfully" 
            end
            #Show confirmation message on page
            flash[:success] = t(:opt_out, store_name: @merchant_store.store_name, :scope => [:business_messages, :web_profile])
            render 'stop_sms'
          else
            logger.debug "Error when deleting subscriber"
            logger.fatal "Error when deleting subscriber"
            flash.now[:alert] = t(:opt_out_error, :scope => [:business_messages, :web_profile])
            render 'stop_sms'
          end
        else
          logger.debug "Error: Subscriber not found in merchant-store"
          logger.fatal "Error: Subscriber not found in merchant-store"
          flash.now[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
          render 'stop_sms'
        end
      else
        logger.debug "Error: Subscriber could not be found. Invalid token used - does not match member access key"
        flash.now[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
        render 'stop_sms'
      end  
    else
      logger.debug "Error: Missing attributes when unsubscribing"
      logger.fatal "Error: Missing attributes when unsubscribing"
      flash[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
      redirect_to root_path
    end
  end

  private
    #Test:OK
    def showMarkers(merchant_stores)
      logger.debug "Creating markers from store search array..."
      member_ships = Hash.new
      if current_member_user && member_user? && current_member_user.subscribers.any?
        current_member_user.subscribers.each do |c|
          member_ships[c.merchant_store_id] = c.id
        end
      end 
      @json = merchant_stores.to_gmaps4rails do |merchant, marker|
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
                  :picture => ActionController::Base.helpers.asset_path("map_signed_up.png"),
                  :width   => 32,
                  :height  => 32
                 })   
        end
        marker.title merchant.store_name
        marker.json({ :merchant_id => merchant.id })
      end
      return @json 
    end#End showMarkers

end#End class




