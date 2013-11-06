class MemberSubscribersController < ApplicationController
	before_filter :member_user
	
  #Via Google Maps
  def subscribe
    @member = Member.find( params[:subscriber][:member_id] )
    @merchant_store = MerchantStore.find( params[:subscriber][:merchant_store_id] )
    @subscriber = @merchant_store.subscribers.find_by_member_id(@member.id)
    #Two states: New subscriber or inactive subscriber. In the latter case, subscriber has been active before for this store
    if @subscriber.nil? || !@subscriber.active
      processSignup(@member, @subscriber, @merchant_store, "web")
      #Necessary to reload since @subscriber is used in unsubscribe view - after a subscribe action, the unsubscribe view snippet is loaded
      @subscriber_reload
    end
    #else
      #render :nothing => true
                #
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js  
    end
  end

  #Via Google Maps
  def unsubscribe
    @subscriber = @current_resource
    @merchant_store = MerchantStore.find(@subscriber.merchant_store.id)
    if @subscriber.present? && @subscriber.active && @merchant_store.present?
      @subscriber.opt_out
      @subscriber.save!
      #Send opt-out e-mail to member
      MemberMailer.delay.web_opt_out(@subscriber.member.id, @merchant_store.id)
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
    @subscriber = @current_resource
    @merchant_store = MerchantStore.find(@subscriber.merchant_store.id)
    if @subscriber.present? && @subscriber.active && @merchant_store.present?
      @subscriber.opt_out
      @subscriber.save!
      #Send opt-out e-mail to member
      MemberMailer.delay.web_opt_out(@subscriber.member.id, @merchant_store.id)
      flash[:success] = t( :unsubscribe_confirmation, store_name: @merchant_store.store_name, :scope => [:business_messages, :subscriber])
      redirect_to favorites_path(@subscriber.member.id)
    else
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
