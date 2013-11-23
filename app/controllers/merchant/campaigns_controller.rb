class Merchant::CampaignsController < Merchant::BaseController
  #If-override-from-base: layout "merchant", except: [:index]

  def active
    logger.info "Loading campaign active action"
    @active_campaigns = current_merchant_store.campaigns.where("activation_time > :date_now", :date_now => Time.now).page(params[:page]).per_page(10)
    logger.debug "List with active campaigns: #{@active_campaigns.inspect}"
  end

  def finished
    logger.info "Loading campaign finished action"
    @completed_campaigns = current_merchant_store.campaigns.where("activation_time < :date_now", :date_now => Time.now).page(params[:page]).per_page(10)
    logger.debug "List with finished campaigns: #{@completed_campaigns.inspect}"
  end 

  def index
  end
  
  def show
    logger.info "Loading campaign show action"
    @campaign = current_resource
    @campaign_members = @campaign.campaign_members.page(params[:page]).per_page(10)
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    logger.debug "Campaign members attributes hash: #{@campaign_members.inspect}"
    @message_with_stop_link = @campaign.message + "\nStop: STOP #{current_merchant_store.sms_keyword} til 1276 222"
    logger.debug "Stop link: #{@stop_link.inspect}"
  end
  
  def new
    logger.info "Loading campaign new action"
    @campaign = Campaign.new
    #Used for max-length property in textarea
    @message_limit = 160 - 30 #Safe guess on bitly length.
    logger.debug "Message limit: #{@message_limit.inspect}"
    #SMS stop link - if we decide to go with this option
    @stop_link = "\nStop: STOP #{current_merchant_store.sms_keyword} til 1276 222"
    logger.debug "Stop link: #{@stop_link.inspect}"
  end

  def edit
    logger.info "Loading campaign edit action"
    @campaign = current_resource
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    #Used for max-length property in textarea
    @message_limit = 160 - 30 #Safe guess on bitly length.
    logger.debug "Message limit: #{@message_limit.inspect}"
    #SMS stop link - if we decide to go with this option
    @stop_link = "\nStop: STOP #{current_merchant_store.sms_keyword} til 1276 222"
    logger.debug "Stop link: #{@stop_link.inspect}"
  end

  def create
    logger.info "Loading campaign create action"
    #Used for max-length property in textarea
    @message_limit = 160 - 30 #Safe guess on bitly length.
    logger.debug "Message limit: #{@message_limit.inspect}"
    #SMS stop link - if we decide to go with this option
    @stop_link = "\nStop: STOP #{current_merchant_store.sms_keyword} til 1276 222"
    logger.debug "Stop link: #{@stop_link.inspect}"
    
    #Step 1: Opret selve kampagnen først
    @campaign = current_merchant_store.campaigns.build(params[:campaign])
    logger.debug "Building new empty campaign - attributes hash: #{@campaign.attributes.inspect}"
    
    #Conduct mandatory check of 5 minute create window - only one new campaign every 5 minutes to avoid double submission
    if(!current_merchant_store.campaigns.where(:created_at => (Time.zone.now - 5.minutes)..Time.zone.now).exists? )
      logger.debug "5 minute window validation OK"
      #Default add all members for a store
      if @campaign.save
        logger.debug "Campaign initial save OK"
        #Step 2: Tilføj default alle medlemmer i kundeklubben til kampagnen. Dette skal ændres senere.
        logger.info "Adding subscriber members"
        current_merchant_store.subscribers.each do |subscriber| 
          logger.debug "Subscriber member - attributes hash: #{subscriber.attributes.inspect}"
          #Only active subscribers are included
          if subscriber.active
            logger.debug "Subscriber active OK - added"
            @campaign.campaign_members.create!(subscriber_id: subscriber.id, status: 'new') 
          end
        end
        logger.debug "Subscriber members total: #{@campaign.campaign_members.size.inspect}"

        #Vigtigt! http://stackoverflow.com/questions/10061937/calling-classes-in-lib-from-controller-actions
        if SMSUtility::SMSFactory.sendOfferReminderScheduled?(@campaign, current_merchant_store)
          logger.debug "Campaign confirmed in SMS gateway"
          @campaign.status = 'scheduled'
          @campaign.save
          logger.debug "Campaign saved sucessfully- attributes hash: #{@campaign.attributes.inspect}"
          flash[:success] = t(:campaign_created, :scope => [:business_validations, :campaign])
          redirect_to [:merchant, @campaign]
        else
          logger.debug "Error: Campaign not confirmed in SMS gateway"
          logger.fatal "Error: Campaign not confirmed in SMS gateway"
          @campaign.status = 'error'
          @campaign.save
          logger.debug "Campaign saved sucessfully- attributes hash: #{@campaign.attributes.inspect}"
          flash[:error] = t(:campaign_create_error, :scope => [:business_validations, :campaign])
          redirect_to [:merchant, @campaign]
        end
      else
        logger.debug "Error: Could not save due to validation errors"
        render 'new'
      end
    else
      logger.debug "5 minute window validation ERROR - another campaign already exists in that time frame"
      flash.now[:error] = t(:double_submission, :scope => [:business_validations, :campaign])
      render 'new'
    end#end campaign window validation
  end
 
  def destroy
    logger.info "Loading campaign destroy action"
    @campaign = current_resource
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"

    #Manual validation rule to prevent deleting already active or launched campaigns due to billing reasons
    if (Time.zone.now + 5.minutes) >= @campaign.activation_time 
      flash[:success] = t(:campaign_active_delete_error, :scope => [:business_validations, :campaign])
      redirect_to active_merchant_campaigns_path 
      return
    end

    if SMSUtility::SMSFactory.cancelScheduledOfferReminder?(@campaign)  
      logger.debug "Campaign confirmed deleted in SMS gateway OK"
      @campaign.destroy
      logger.debug "Campaign deleted sucessfully"
      flash[:success] = t(:campaign_deleted, :scope => [:business_validations, :campaign])
      redirect_to active_merchant_campaigns_path 
    else
      logger.debug "Error: Campaign NOT deleted in SMS gateway"
      logger.fatal "Error: Campaign NOT deleted in SMS gateway"
      flash[:error] = t(:campaign_delete_technical_error, :scope => [:business_validations, :campaign]) 
    end
  end

  def update
    logger.info "Loading campaign update action"
    @campaign = current_resource
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    #We need to initialize form attributes again if validation errors are present
    @message_limit = 160 - 30 #Safe guess on bitly length.
    logger.debug "Message limit: #{@message_limit.inspect}"
    #SMS stop link - if we decide to go with this option
    @stop_link = "\nStop: send #{current_merchant_store.sms_keyword} til 1276 222"
    logger.debug "Stop link: #{@stop_link.inspect}"

    #Determine if activation_time has changed
    new_activation_time = false
    if @campaign.activation_time != params[:campaign][:activation_time]
      new_activation_time = true
    end

    logger.debug "Activation time change: #{new_activation_time.inspect}"
    
    #Manual validation rule to prevent updating already completed or launched campaigns due to billing reasons
    if (Time.zone.now + 5.minutes) >= @campaign.activation_time 
      flash[:success] = t(:campaign_late_update_error, :scope => [:business_validations, :campaign])
      redirect_to active_merchant_campaigns_path 
      return
    end

    if @campaign.update_attributes(params[:campaign])
      logger.debug "Campaign updated successfully - attributes hash: #{@campaign.attributes.inspect}"
      status = true
      if new_activation_time
        status = SMSUtility::SMSFactory.reschduleOfferReminder?(@campaign)
      end
      if status
        logger.debug "Campaign updated in SMS Gateway OK"
        flash[:success] = t(:campaign_updated, :scope => [:business_validations, :campaign])
        redirect_to [:merchant, @campaign]
      else
        logger.debug "Error: Campaign NOT updated in SMS gateway"
        logger.fatal "Error: Campaign NOT updated in SMS gateway"
        flash.now[:error] = t(:campaign_update_error, :scope => [:business_validations, :campaign])
        render :edit
      end
    else
      logger.debug "Validation errors. Reloading view with errors"
      render :edit
    end
  end

  def send_test_message
    logger.info "Loading campaign send_test_message action"
    @campaign = current_resource
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    recipient = params[:recipient]
    logger.debug "Recipient: #{recipient.inspect}"

    #message = message + @subscriber.opt_out_link
    stop_link = "\nStop: send #{current_merchant_store.sms_keyword} til 1276 222"
    logger.debug "Stop link: #{stop_link.inspect}"

    message = @campaign.message + stop_link
    logger.debug "message: #{message.inspect}"

    if SMSUtility::SMSFactory.validate_phone_number_converted?(recipient)
      logger.debug "SMS validation OK"
      if SMSUtility::SMSFactory.sendSingleMessageInstant?(message, recipient, current_merchant_store)
        logger.debug "Message confirmed in SMS gateway OK"
        flash[:success] = t(:success, :scope => [:business_validations, :campaign_test_message])
        redirect_to [:merchant, @campaign]
      else
        logger.debug "Error: Message NOT confirmed in SMS gateway"
        logger.fatal "Error: Message NOT confirmed in SMS gateway"
        flash[:error] = t(:error, :scope => [:business_validations, :campaign_test_message])
        redirect_to [:merchant, @campaign]  
      end
    else
      logger.debug "Validation error in message. Loading view with errors"
      flash[:error] = t(:invalid_phone, :scope => [:business_validations, :campaign_test_message])
      redirect_to [:merchant, @campaign]
    end
  end

  private
    def current_resource
      @current_resource ||= Campaign.find(params[:id]) if params[:id]
    end

end#end class


=begin
Backup d. 3.11.13 før delayedjob
def create
      #Step 1: Opret selve kampagnen først
      @campaign = current_merchant_store.campaigns.build(params[:campaign]) 
      #Default add all members for a store
      if @campaign.save
        #Step 2: Tilføj default alle medlemmer i kundeklubben til kampagnen. Dette skal ændres senere.
        current_merchant_store.subscribers.each do |subscriber| 
          #Only active subscribers are included
          if subscriber.active
            @campaign.campaign_members.create!(subscriber_id: subscriber.id, status: 'new') 
          end
        end

        #Vigtigt! http://stackoverflow.com/questions/10061937/calling-classes-in-lib-from-controller-actions
        if SMSUtility::SMSFactory.sendOfferReminderScheduled?(@campaign, current_merchant_store)
          @campaign.status = 'scheduled'
          @campaign.save!
          flash[:success] = t(:campaign_created, :scope => [:business_validations, :campaign])
          redirect_to [:merchant, @campaign]
        else
          @campaign.status = 'error'
          @campaign.save!
          flash[:error] = t(:campaign_create_error, :scope => [:business_validations, :campaign])
          redirect_to [:merchant, @campaign]
        end
      else
        render 'new'
      end
  end


  
=end