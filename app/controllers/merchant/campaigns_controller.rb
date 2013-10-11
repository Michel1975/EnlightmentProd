class Merchant::CampaignsController < Merchant::BaseController
  #If-override-from-base: layout "merchant", except: [:index]

  def index
    @active_campaigns = Campaign.where("activation_time > :date_now", :date_now => Time.now).paginate(page: params[:page], :per_page => 20)
    @completed_campaigns = Campaign.where("activation_time < :date_now", :date_now => Time.now).paginate(page: params[:page], :per_page => 20)
  end 
  
  def show
    @campaign = Campaign.find(params[:id])        
  end
  
  def new
    @campaign = Campaign.new
  end

  def edit
    @campaign = Campaign.find(params[:id])
  end

  #Eftersom oprettelsen af ordren i gateway sker asynkront, så vil vi oprette selve kampagnen først
  def create
      #Step 1: Opret selve kampagnen først
      @campaign = current_merchant_store.campaigns.build(params[:campaign]) 
      #Default add all members for a store
      if @campaign.save!
        #Step 2: Tilføj default alle medlemmer i kundeklubben til kampagnen. Dette skal ændres senere.
        current_merchant_store.subscribers.each do |subscriber| 
          @campaign.campaign_members.create(subscriber_id: subscriber.id, status: 'new') 
        end
        #Vigtigt! http://stackoverflow.com/questions/10061937/calling-classes-in-lib-from-controller-actions
        if SMSUtility::SMSFactory.sendOfferReminderScheduled?(@campaign)
          @campaign.status = 'scheduled'
          @campaign.save!
          flash[:success] = t(:campaign_created, :scope => [:business_validations, :campaign])
          redirect_to merchant_campaigns_path
        else
          @campaign.status = 'error'
          @campaign.save!
          flash[:alert] = t(:campaign_error, :scope => [:business_validations, :campaign])
          redirect_to [:merchant, @campaign]
        end
      else
        render 'new'
      end
  end
 
  def destroy
    @campaign = Campaign.find(params[:id])
    SMSFactory.cancelScheduledOfferReminder?(@campaign)    	
    @campaign.destroy
    flash[:success] = t(:campaign_deleted, :scope => [:business_validations, :campaign])
    redirect_to merchant_campaigns_path
  end

  def update
    @campaign = Campaign.find(params[:id])    
    @campaign.update_attributes(params[:campaign])
    if SMSFactory.reschduleOfferReminder?(@campaign)
      flash[:success] = t(:campaign_updated, :scope => [:business_validations, :campaign])
      redirect_to [:merchant, @campaign]
    end
  end

end
