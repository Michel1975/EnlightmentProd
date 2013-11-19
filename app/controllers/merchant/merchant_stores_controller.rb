class Merchant::MerchantStoresController < Merchant::BaseController
  #If-override-from-base: layout "merchant", except: [:index]
  
  def sms_qrcode
    logger.info "Loading merchant_store sms_qrcode action"
    @merchant_store = current_resource
    logger.debug "Merchant_store attributes hash: #{@merchant_store.attributes.inspect}"
  end

  def edit
    logger.info "Loading merchant_store edit action"
    @merchant_store = current_resource
    logger.debug "Merchant_store attributes hash: #{@merchant_store.attributes.inspect}"
    if @merchant_store.image.nil?
      logger.debug "No image detected. Building new image record"
      @merchant_store.build_image()
    end
  end

  def update
    logger.info "Loading merchant_store update action"
    @merchant_store = current_resource
    logger.debug "Merchant_store attributes hash: #{@merchant_store.attributes.inspect}"
    if @merchant_store.update_attributes(params[:merchant_store])
        logger.debug "Merchant_store updated successfully: #{@merchant_store.attributes.inspect}"
      	flash[:success] = t(:information_updated, :scope => [:business_validations, :merchant_store])        
      	redirect_to [:merchant, @merchant_store]
    else
        logger.debug "Validation errors. Loading edit view with errors"
      	render 'edit'
    end
  end

  def show
    logger.info "Loading merchant_store show action"
    @merchant_store = current_resource
    logger.debug "Merchant_store attributes hash: #{@merchant_store.attributes.inspect}"
  end

  def active_subscription
    logger.info "Loading merchant_store active_subscription action"
    @merchant_store = current_resource #Old: current_merchant_store
    logger.debug "Merchant_store attributes hash: #{@merchant_store.attributes.inspect}"
    @subscription = @merchant_store.subscription_plan
    logger.debug "Subscription plan: #{@subscription.attributes.inspect}"
    @features = @subscription.subscription_type.features
    logger.debug "Features: #{@features.inspect}"
    @number_of_messages_month = @merchant_store.message_notifications.month_total_messages.length
    logger.debug "Number of messages per month: #{@number_of_messages_month.inspect}"
    @running_total_month =  @subscription.subscription_type.monthly_price + (@number_of_messages_month * 0.25)
    logger.debug "Running total for this month: #{@running_total_month.inspect}"
  end

  private
    def current_resource
      @current_resource ||= MerchantStore.find(params[:id]) if params[:id]
    end

end