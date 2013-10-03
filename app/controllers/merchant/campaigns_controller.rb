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
      @campaign.status = 'scheduled'
      #Default add all members for a store
      @campaign.save!
      current_merchant_store.subscribers.each do |subscriber| 
        @campaign.campaign_members.create(subscriber_id: subscriber.id, status: 'new') 
      end
     
      #Step 2: Bestem om ordren sker omgående eller i fremtiden
      if(@campaign.instant_activation)
        #sendOfferReminderInstant?(@campaign, Array.new << Member.new(phone: '+4524600819')) #Member.find(1,10))         
      else
        #sendOfferReminderScheduled?(@campaign, Array.new << Member.new(phone: '+4524600819')) #Member.find(1,10))          
      end
      flash[:success] = t(:campaign_created, :scope => [:business_validations, :campaign])

      #Old: sendSingleMessageScheduled?('Test - Velkommen til Club Novus', '+4524600819','2013-08-03T15:55:00')
      redirect_to merchant_campaigns_path
  end
 
  def destroy
    #To-Do: Foretag kald til gateway og aflys udsendelse af sms-er
    @campaign = Campaign.find(params[:id])
    #cancelScheduledOfferReminder?(@campaign)    	
    @campaign.destroy
    flash[:success] = t(:campaign_deleted, :scope => [:business_validations, :campaign])
    redirect_to merchant_campaigns_path
  end

  def update
    @campaign = Campaign.find(params[:id])    
    @campaign.update_attributes(params[:campaign])
    #reschduleOfferReminder?(@campaign)
    flash[:success] = t(:campaign_updated, :scope => [:business_validations, :campaign])

    redirect_to [:merchant, @campaign]
  end

end
