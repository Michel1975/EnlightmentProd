class MemberSubscribersController < ApplicationController
	before_filter :member_user
	
  #Via Google Maps
  def subscribe
    logger.info "Loading MemberSubscriber subscribe action - remote"
    @member = Member.find( params[:subscriber][:member_id] )
    logger.debug "Member attributes hash: #{@member.attributes.inspect}"
    @merchant_store = MerchantStore.find( params[:subscriber][:merchant_store_id] )
    logger.debug "Merchant-store attributes hash: #{@merchant_store.attributes.inspect}"
    @subscriber = @merchant_store.subscribers.find_by_member_id(@member.id)
    #Two states: New subscriber or inactive subscriber. In the latter case, subscriber has been active before for this store
    if @subscriber.nil? || !@subscriber.active
      logger.debug "Calling processSignup method"
      processSignup(@member, @subscriber, @merchant_store, "web")
      #Necessary to reload since @subscriber is used in unsubscribe view - after a subscribe action, the unsubscribe view snippet is loaded
      @subscriber_reload
      logger.debug "Subscriber reloaded"
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
    if @subscriber.present? && @subscriber.active && @merchant_store.present?
      logger.debug "Subscriber found in database. Starting unsubscribe process: #{@subscriber.attributes}"
      @subscriber.opt_out
      @subscriber.save!
      logger.debug "Unsubscribe completed successfully: #{@subscriber.attributes}"
      #Send opt-out e-mail to member
      MemberMailer.delay.web_opt_out(@subscriber.member.id, @merchant_store.id)
      logger.debug "Sending delayed unsubscribe email to member"
    end
    #else
      #render :nothing => true
    #redirect_to root_path
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js  
    end
  end

  #Via frontend favorite list
  def unsubscribe_member_table
    logger.info "Loading MemberSubscriber unsubscribe_member_table action"
    @subscriber = @current_resource
    logger.debug "Subscriber attributes hash: #{@subscriber.attributes.inspect}"
    @merchant_store = MerchantStore.find(@subscriber.merchant_store.id)
    logger.debug "Merchant-store attributes hash: #{@merchant_store.attributes.inspect}"

    if @subscriber.present? && @subscriber.active && @merchant_store.present?
      logger.debug "Subscriber found in database. Starting unsubscribe process: #{@subscriber.attributes}"
      @subscriber.opt_out
      @subscriber.save!
      logger.debug "Unsubscribe completed successfully: #{@subscriber.attributes}"

      #Send opt-out e-mail to member
      MemberMailer.delay.web_opt_out(@subscriber.member.id, @merchant_store.id)
      logger.debug "Sending delayed unsubscribe email to member"

      flash[:success] = t( :unsubscribe_confirmation, store_name: @merchant_store.store_name, :scope => [:business_messages, :subscriber])
      redirect_to favorites_path(@subscriber.member.id)
    else
      logger.debug "Error: Invalid unsubscribe request. Missing attributes"
      logger.fatal "Error: Invalid unsubscribe request. Missing attributes"
      #To-Do: Tekniske fejl kan fanges her.
      render 'favorites'
    end
  end

  private
    #Used for security controlled for specific actions
    def current_resource
      @current_resource ||= Subscriber.find( params[:id] ) if params[:id]
    end

end
