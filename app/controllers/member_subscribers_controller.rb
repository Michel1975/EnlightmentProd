class MemberSubscribersController < ApplicationController
	before_filter :member_user
	
  #Via Google Maps
  def subscribe
    logger.info "Loading MemberSubscriber subscribe action - remote"
    @member = Member.find( params[:subscriber][:member_id] )
    logger.debug "Member attributes hash: #{@member.attributes.inspect}" if @member
    @merchant_store = MerchantStore.find( params[:subscriber][:merchant_store_id] )
    logger.debug "Merchant-store attributes hash: #{@merchant_store.attributes.inspect}" if @merchant_store
    if @member && @merchant_store
      @subscriber = @merchant_store.subscribers.find_by_member_id(@member.id)
      if @subscriber.nil? 
        logger.debug "Calling processSignup method"
        processSignup(@member, @merchant_store, "web")
      end
    end

    respond_to do |format|
      #format.html { redirect_to root_path }
      format.js  
    end
  end

  #Via Google Maps
  def unsubscribe
    logger.info "Loading MemberSubscriber unsubscribe action - remote"
    @subscriber = @current_resource
    logger.debug "Subscriber attributes hash: #{@subscriber.attributes.inspect}" if @subscriber
    @merchant_store = MerchantStore.find(@subscriber.merchant_store.id)
    logger.debug "Merchant-store attributes hash: #{@merchant_store.attributes.inspect}" if @merchant_store
    if @subscriber.present? && @merchant_store.present?
      logger.debug "Subscriber found in database. Starting unsubscribe process: #{@subscriber.attributes}"
      if @subscriber.destroy
        logger.debug "Unsubscribe completed successfully: #{@subscriber.attributes}"
        #Send opt-out e-mail to member
        MemberMailer.delay.web_opt_out(@subscriber.member.id, @merchant_store.id)
        logger.debug "Sending delayed unsubscribe email to member"
      else
        logger.debug "Error unsubscribing via Google Maps" 
        logger.fatal "Error unsubscribing via Google Maps" 
      end
    end
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js  
    end
  end

  #Via frontend favorite list
  def unsubscribe_member_table
    logger.info "Loading MemberSubscriber unsubscribe_member_table action"
    @subscriber = @current_resource
    logger.debug "Subscriber attributes hash: #{@subscriber.attributes.inspect}" if @subscriber
    @merchant_store = MerchantStore.find(@subscriber.merchant_store.id)
    logger.debug "Merchant-store attributes hash: #{@merchant_store.attributes.inspect}" if @merchant_store
    error = false
    if @subscriber.present? && @merchant_store.present?
      logger.debug "Subscriber found in database. Starting unsubscribe process: #{@subscriber.attributes}"
        if @subscriber.destroy
          logger.debug "Unsubscribe completed successfully"
          
          #Send opt-out e-mail to member
          MemberMailer.delay.web_opt_out(@subscriber.member.id, @merchant_store.id)
          logger.debug "Sending delayed unsubscribe email to member"
          flash[:success] = t( :unsubscribe_confirmation, store_name: @merchant_store.store_name, :scope => [:business_messages, :subscriber])
          redirect_to favorites_path(current_member_user)
          return
        else
          error = true
          logger.debug "Error when deleting subscriber record"
        end
    else
      error = true
      logger.debug "Error: Invalid unsubscribe request. Missing attributes"
      logger.fatal "Error: Invalid unsubscribe request. Missing attributes"
    end
    if error
        flash[:error] = t( :unsubscribe_error, store_name: @merchant_store.store_name, :scope => [:business_messages, :subscriber])
        redirect_to favorites_path(current_member_user)
    end
  end

  private
    #Used for security controlled for specific actions
    def current_resource
      @current_resource ||= Subscriber.find( params[:id] ) if params[:id]
    end

end#End class
