class MemberSubscribersController < ApplicationController
	before_filter :member_user
	
  #Via google maps
  def subscribe
	@member = current_resource #Old: Member.find(params[:subscriber][:member_id])
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

  #Via google maps
  def unsubscribe
  	member = current_resource
    @subscriber = Subscriber.find_by_member_id(member)
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

  private
    def current_resource
    	if params[:id]
    		@current_resource ||= Member.find(params[:id])
    	elsif params[:subscriber][:member_id]
    		@current_resource ||= Member.find(params[:subscriber][:member_id])	
    	end
    end

end
