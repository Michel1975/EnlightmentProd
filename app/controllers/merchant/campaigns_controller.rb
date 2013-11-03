class Merchant::CampaignsController < Merchant::BaseController
  #If-override-from-base: layout "merchant", except: [:index]

  def active
    @active_campaigns = current_merchant_store.campaigns.where("activation_time > :date_now", :date_now => Time.now).page(params[:page]).per_page(10)
  end

  def finished
    @completed_campaigns = current_merchant_store.campaigns.where("activation_time < :date_now", :date_now => Time.now).page(params[:page]).per_page(10)
  end 

  def index
  end
  
  def show
    @campaign = current_resource
    @campaign_members = @campaign.campaign_members.page(params[:page]).per_page(10)
  end
  
  def new
    @campaign = Campaign.new
    #Used for max-length property in textarea
    @message_limit = 160 - 30 #Safe guess on bitly length.
    #SMS stop link - if we decide to go with this option
    @stop_link = "\nStop: send #{current_merchant_store.sms_keyword} til 1276 222"
  end

  def edit
    @campaign = current_resource
    #Used for max-length property in textarea
    @message_limit = 160 - 30 #Safe guess on bitly length.
    #SMS stop link - if we decide to go with this option
    @stop_link = "\nStop: send #{current_merchant_store.sms_keyword} til 1276 222"
  end

  #Eftersom oprettelsen af ordren i gateway sker asynkront, så vil vi oprette selve kampagnen først
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
 
  def destroy
    @campaign = current_resource
    if SMSUtility::SMSFactory.cancelScheduledOfferReminder?(@campaign)  
      @campaign.destroy
      flash[:success] = t(:campaign_deleted, :scope => [:business_validations, :campaign])
      redirect_to active_merchant_campaigns_path 
    else
      flash[:error] = t(:campaign_delete_error, :scope => [:business_validations, :campaign]) 
    end
  end

  def update
    @campaign = current_resource

    #We need to initialize form attributes again if validation errors are present
    @message_limit = 160 - 30 #Safe guess on bitly length.
    #SMS stop link - if we decide to go with this option
    @stop_link = "\nStop: send #{current_merchant_store.sms_keyword} til 1276 222"

    #Determine if activation_time has changed
    new_activation_time = false
    if @campaign.activation_time != params[:campaign][:activation_time]
      new_activation_time = true
    end

    if @campaign.update_attributes(params[:campaign])
      status = true
      if new_activation_time
        status = SMSUtility::SMSFactory.reschduleOfferReminder?(@campaign)
      end
      if status
        flash[:success] = t(:campaign_updated, :scope => [:business_validations, :campaign])
        redirect_to [:merchant, @campaign]
      else
        flash.now[:error] = t(:campaign_update_error, :scope => [:business_validations, :campaign])
        render :edit
      end
    else
      render :edit
    end
  end

  def send_test_message
    @campaign = current_resource
    recipient = params[:recipient]
    #message = message + @subscriber.opt_out_link
    stop_link = "\nStop: send #{current_merchant_store.sms_keyword} til 1276 222"
    message = @campaign.message + stop_link
    if SMSUtility::SMSFactory.validate_phone_number_converted?(recipient)
      if SMSUtility::SMSFactory.sendSingleMessageInstant?(message, recipient, current_merchant_store)
        flash[:success] = t(:success, :scope => [:business_validations, :campaign_test_message])
        redirect_to [:merchant, @campaign]
      else
        flash[:error] = t(:error, :scope => [:business_validations, :campaign_test_message])
        redirect_to [:merchant, @campaign]  
      end
    else
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