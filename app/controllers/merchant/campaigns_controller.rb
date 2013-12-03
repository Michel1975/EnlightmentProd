class Merchant::CampaignsController < Merchant::BaseController
  #Test:OK
  def active
    logger.info "Loading Campaign active action"
    @active_campaigns = current_merchant_store.campaigns.where("activation_time > :date_now AND status IN (:status_flags)", :date_now => Time.now, :status_flags => ['new', 'scheduled', 'gateway_confirmed', 'error'] ).page(params[:page]).per_page(10)
    logger.debug "List with active campaigns: #{@active_campaigns.inspect}"

    @campaign_status = ENV['SMS_GATEWAY_ACTIVE']
    if @campaign_status == "false"
      logger.debug "SMS Gateway flag: #{@campaign_status.inspect}"
      #Prevent showing two flashs about gateway inactivity
      if flash.empty?
        flash.now[:alert] = t(:gateway_inactive, :scope => [:system])
      end
    end
  end

  #Test:OK
  def finished
    logger.info "Loading Campaign finished action"
    @completed_campaigns = current_merchant_store.campaigns.where("activation_time < :date_now AND status IN (:status_flags)", :date_now => Time.now, :status_flags => ['status_retrived_once','completed', 'error'] ).page(params[:page]).per_page(10)
    logger.debug "List with finished campaigns: #{@completed_campaigns.inspect}"

    @campaign_status = ENV['SMS_GATEWAY_ACTIVE']
    if @campaign_status == "false"
      logger.debug "SMS Gateway flag: #{@campaign_status.inspect}"
      #Prevent showing two flashs about gateway inactivity
      if flash.empty?
        flash.now[:alert] = t(:gateway_inactive, :scope => [:system])
      end
    end
  end 

  def index
  end
  
  def show
    logger.info "Loading Campaign show action"
    @campaign = current_resource
    @campaign_members = @campaign.campaign_members.page(params[:page]).per_page(10)
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    logger.debug "Campaign members attributes hash: #{@campaign_members.inspect}"
    @message_with_stop_link = @campaign.message + current_merchant_store.static_stop_link
    logger.debug "Stop link: #{@message_with_stop_link.inspect}"
  end
  
  def new
    logger.info "Loading Campaign new action"
    @campaign = Campaign.new

    @stop_link = current_merchant_store.static_stop_link
    logger.debug "Stop link: #{@stop_link.inspect}"
    
    #Used for max-length property in textarea
    @message_limit = 160 - current_merchant_store.static_stop_link.length
    logger.debug "Message limit: #{@message_limit.inspect}"
    @campaign_status = ENV['SMS_GATEWAY_ACTIVE']
    logger.debug "SMS Gateway flag: #{@campaign_status.inspect}"
  end

  def edit
    logger.info "Loading campaign edit action"
    @campaign = current_resource
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    @stop_link = current_merchant_store.static_stop_link
    logger.debug "Stop link: #{@stop_link.inspect}"

    #Used for max-length property in textarea
    @message_limit = 160 - current_merchant_store.static_stop_link.length
    logger.debug "Message limit: #{@message_limit.inspect}"

    @campaign_status = ENV['SMS_GATEWAY_ACTIVE']
    logger.debug "SMS Gateway flag: #{@campaign_status}"
  end

  def create
    logger.info "Loading Campaign create action"

    @campaign_status = ENV['SMS_GATEWAY_ACTIVE']
    logger.debug "SMS Gateway flag: #{@campaign_status.inspect}"
    
    if @campaign_status == "true"
      logger.debug "Gateway status is active...proceeding"
      no_subscribers = current_merchant_store.subscribers.count
      logger.debug "Number of subscribers for campaign - #{no_subscribers.inspect}"
      
      #Validate monthly message limits
      if current_merchant_store.validate_monthly_message_limit?(no_subscribers)
        logger.debug "Monthly message limit OK for store...proceeding"
        
        @stop_link = current_merchant_store.static_stop_link
        logger.debug "Stop link: #{@stop_link.inspect}"

        #Used for max-length property in textarea
        @message_limit = 160 - current_merchant_store.static_stop_link.length
        logger.debug "Message limit: #{@message_limit.inspect}"

        #Step 1: Opret selve kampagnen først
        @campaign = current_merchant_store.campaigns.build(params[:campaign])
        logger.debug "Building new empty campaign object - attributes hash: #{@campaign.attributes.inspect}"
        
        #Conduct mandatory check of 5 minute create window - only one new campaign every 5 minutes to avoid double submission
        if(!current_merchant_store.campaigns.where(:created_at => (Time.zone.now - 5.minutes)..Time.zone.now).exists? )
          logger.debug "5 minute window validation OK"
          @campaign.status = 'scheduled'
          #Default add all members for a store
          #Need to include valid for timing reasons in campaign validation logic
          if @campaign.valid? && @campaign.save
            logger.debug "Campaign saved successfully"
            logger.debug "Updating event log for store..."
            m_user = MerchantUser.find(current_user.sub_id)
            log_event_history_merchant_portal(current_merchant_store, "campaign-created", "#{m_user.name.inspect} oprettede en ny kampagne")

            #Step 2: Tilføj default alle medlemmer i kundeklubben til kampagnen. Dette skal ændres senere.
            logger.info "Adding campaign members => all current subscribers of this store..."
            current_merchant_store.subscribers.each do |subscriber| 
              logger.debug "Subscriber member - attributes hash: #{subscriber.attributes.inspect}"
              #Only confirmed phone numbers
              if subscriber.member.phone_confirmed
                @campaign.campaign_members.create!(subscriber_id: subscriber.id, status: 'new')
              end 
            end
            logger.debug "Subscriber members total: #{@campaign.campaign_members.count.inspect}"
            flash[:success] = t(:campaign_created, :scope => [:business_validations, :campaign])
            redirect_to [:merchant, @campaign]
          else
            logger.debug "Error: Could not save due to validation errors"
            render 'new'
          end
        else
          logger.debug "5 minute window validation ERROR - another campaign already exists in that time frame"
          flash.now[:error] = t(:double_submission, :scope => [:business_validations, :campaign])
          render 'new'
        end#end campaign window validation
      else
        logger.debug "Monthly message limit is broken. Cannot create campaign"
        flash[:error] = t(:monthly_message_limit_broken, total_messages: SMSUtility::STORE_TOTAL_MESSAGES_MONTH, :scope => [:system])
        redirect_to active_merchant_campaigns_path
      end#End message limit validation
    else
      logger.debug "SMS Gateway is set to inactive - thus new campaigns cannot be created"
      flash[:error] = t(:gateway_inactive_campaign, :scope => [:system])
      redirect_to active_merchant_campaigns_path
    end#End if gateway active
  end
 
  def destroy
    logger.info "Loading campaign destroy action"
    @campaign = current_resource
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"

    #Manual validation rule to prevent deleting already active or launched campaigns due to billing reasons
    if (Time.zone.now + 30.minutes) >= @campaign.activation_time
      logger.debug "Attempt to delete campaign less than 30 minutes before activation...not possible" 
      flash[:alert] = t(:campaign_active_delete_error, :scope => [:business_validations, :campaign])
      redirect_to active_merchant_campaigns_path 
      return
    end

    logger.debug "Trying to determine if campaign is confirmed by gateway"
    if @campaign.status == "gateway_confirmed"
      logger.debug "Campaign is confirmed by gateway - #{@campaign.status.inspect}"
      logger.debug "Need to delete campaign in both gateway and database"
      delete_status = false
      if SMSUtility::SMSFactory.cancelScheduledOfferReminder?(@campaign) 
        logger.debug "Campaign confirmed successfully deleted in SMS gateway => OK"
        if @campaign.destroy
          delete_status = true
          logger.debug "Campaign deleted successfully in database as well => OK"
        end
      end
    else
      logger.debug "Campaign is NOT confirmed by gateway - #{@campaign.status.inspect}"
      logger.debug "Need to delete campaign in database only"
      if @campaign.destroy
        delete_status = true
        logger.debug "Campaign deleted successfully in database as well => OK"
      end
    end

    if delete_status
      logger.debug "Delete status is positive - #{delete_status.inspect}"
      m_user = MerchantUser.find(current_user.sub_id)
      log_event_history_merchant_portal(current_merchant_store, "campaign-cancelled", "#{m_user.name.inspect} annullerede en kampagne")
      flash[:success] = t(:campaign_deleted, :scope => [:business_validations, :campaign])
      redirect_to active_merchant_campaigns_path  
    else
      logger.debug "Delete status is negative - #{delete_status.inspect}"
      logger.debug "Error: Campaign NOT deleted in SMS gateway or database"
      logger.fatal "Error: Campaign NOT deleted in SMS gateway or database"
      flash[:error] = t(:campaign_delete_technical_error, :scope => [:business_validations, :campaign])  
    end
  end

  def update
    logger.info "Loading campaign update action"
    @campaign = current_resource
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    
    @campaign_status = ENV['SMS_GATEWAY_ACTIVE']
    logger.debug "SMS Gateway flag: #{@campaign_status.inspect}"

    if @campaign_status == "true"
      #We need to initialize form attributes again if validation errors are present
      @stop_link = current_merchant_store.static_stop_link
      logger.debug "Stop link: #{@stop_link.inspect}"

      #Used for max-length property in textarea
      @message_limit = 160 - current_merchant_store.static_stop_link.length
      logger.debug "Message limit: #{@message_limit.inspect}"

      logger.debug "Determine if any change to activation time..."
      logger.debug "Old activation time: #{@campaign.activation_time.inspect}"
      new_activation_time = params[:campaign][:activation_time]
      logger.debug "New activation time: #{new_activation_time.inspect}"
      #Determine if activation_time has changed
      new_activation_time = false
      if @campaign.activation_time != params[:campaign][:activation_time]
        logger.debug "Activation time has changed"
        new_activation_time = true
      end
      
      #Manual validation rule to prevent updating already completed or launched campaigns due to billing reasons
      if (Time.zone.now + 30.minutes) >= @campaign.activation_time 
        logger.debug "Attempt to edit campaign less than 30 minutes before activation...not possible"
        flash[:alert] = t(:campaign_late_update_error, :scope => [:business_validations, :campaign])
        redirect_to active_merchant_campaigns_path 
        return
      end

      if @campaign.update_attributes(params[:campaign])
        logger.debug "Campaign updated successfully in database - attributes hash: #{@campaign.attributes.inspect}"
        logger.debug "Updating eventhistory"
        m_user = MerchantUser.find(current_user.sub_id)
        log_event_history_merchant_portal(current_merchant_store, "campaign-edited", "#{m_user.name.inspect} opdaterede en kampagne")
        status = false
        if new_activation_time && @campaign.status == "gateway_confirmed"
          status = SMSUtility::SMSFactory.reschduleOfferReminder?(@campaign)
        end
        if status
          logger.debug "Campaign updated in SMS Gateway => OK"
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
    else
      logger.debug "SMS Gateway is set to inactive - thus campaigns cannot be updated"
      flash[:error] = t(:gateway_inactive, :scope => [:system])
      redirect_to [:merchant, @campaign] 
    end
  end

  def send_test_message
    logger.info "Loading campaign send_test_message action"
    @campaign = current_resource
    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    recipient = params[:recipient]
    logger.debug "Recipient: #{recipient.inspect}"

    @campaign_status = ENV['SMS_GATEWAY_ACTIVE']
    logger.debug "SMS Gateway flag: #{@campaign_status.inspect}"
    
    if @campaign_status == "true"
      logger.debug "SMS Gateway flag is active...proceeding"

      #Validate monthly message limits
      if current_merchant_store.validate_monthly_message_limit?(1)

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
      else
        logger.debug "Monthly message limit is broken. Cannot create send message"
        flash[:error] = t(:monthly_message_limit_broken, total_messages: SMSUtility::STORE_TOTAL_MESSAGES_MONTH, :scope => [:system])
        redirect_to [:merchant, @campaign]
      end
    else
      logger.debug "SMS Gateway is set to inactive - message cannot be sent"
      flash[:error] = t(:gateway_inactive, :scope => [:system])
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

=begin
def create
    logger.info "Loading Campaign create action"

    @campaign_status = ENV['SMS_GATEWAY_ACTIVE']
    logger.debug "SMS Gateway flag: #{@campaign_status.inspect}"
    
    if @campaign_status == "true"
      logger.debug "Gateway status is active...proceeding"
      no_subscribers = current_merchant_store.subscribers.count
      logger.debug "Number of subscribers for campaign - #{no_subscribers.inspect}"
      
      #Validate monthly message limits
      if current_merchant_store.validate_montly_message_limit?(no_subscribers)
        logger.debug "Monthly message limit OK for store...proceeding"
        
        @stop_link = current_merchant_store.static_stop_link
        logger.debug "Stop link: #{@stop_link.inspect}"

        #Used for max-length property in textarea
        @message_limit = 160 - current_merchant_store.static_stop_link.length
        logger.debug "Message limit: #{@message_limit.inspect}"

        #Step 1: Opret selve kampagnen først
        @campaign = current_merchant_store.campaigns.build(params[:campaign])
        logger.debug "Building new empty campaign object - attributes hash: #{@campaign.attributes.inspect}"
        
        #Conduct mandatory check of 5 minute create window - only one new campaign every 5 minutes to avoid double submission
        if(!current_merchant_store.campaigns.where(:created_at => (Time.zone.now - 5.minutes)..Time.zone.now).exists? )
          logger.debug "5 minute window validation OK"
          #Default add all members for a store
          if @campaign.save
            logger.debug "Campaign initial save OK"
            #Step 2: Tilføj default alle medlemmer i kundeklubben til kampagnen. Dette skal ændres senere.
            logger.info "Adding campaign members => all current members of store..."
            current_merchant_store.subscribers.each do |subscriber| 
              logger.debug "Subscriber member - attributes hash: #{subscriber.attributes.inspect}"
              @campaign.campaign_members.create!(subscriber_id: subscriber.id, status: 'new') 
            end
            logger.debug "Subscriber members total: #{@campaign.campaign_members.count.inspect}"

            #Vigtigt! http://stackoverflow.com/questions/10061937/calling-classes-in-lib-from-controller-actions
            if SMSUtility::SMSFactory.sendOfferReminderScheduled?(@campaign, current_merchant_store)
              logger.debug "Campaign confirmed in SMS gateway"
              @campaign.status = 'scheduled'
              @campaign.save
              m_user = MerchantUser.find(current_user.sub_id)
              log_event_history_merchant_portal(current_merchant_store, "campaign-created", "#{m_user.name} oprettede en ny kampagne")
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
      else
        logger.debug "Monthly message limit is broken. Cannot create campaign"
        flash[:error] = t(:monthly_message_limit_broken, total_messages: SMSUtility::STORE_TOTAL_MESSAGES_MONTH, :scope => [:system])
        redirect_to active_merchant_campaigns_path
      end#End message limit validation
    else
      logger.debug "SMS Gateway is set to inactive - thus new campaigns cannot be created"
      flash[:error] = t(:gateway_inactive_campaign, :scope => [:system])
      redirect_to active_merchant_campaigns_path
    end#End if gateway active
  end 

  
=end