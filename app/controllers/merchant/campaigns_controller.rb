class Merchant::CampaignsController < Merchant::BaseController
	before_filter :require_login #man skal være merchantuser
	layout :determine_layout
  
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

      #Step 2: To-Do - opret grupper som brugeren har valgt at sende til. Disse data ligger i join-objektet      
    	
      #Step 2: Bestem om ordren sker omgående eller i fremtiden
      if(@campaign.instant_activation)
        #sendOfferReminderInstant?(@campaign, Array.new << Member.new(phone: '+4524600819')) #Member.find(1,10))         
      else
        #sendOfferReminderScheduled?(@campaign, Array.new << Member.new(phone: '+4524600819')) #Member.find(1,10))          
      end
      @campaign.save!
      flash[:success] = "Kampagne er blevet oprettet"

      #Old: sendSingleMessageScheduled?('Test - Velkommen til Club Novus', '+4524600819','2013-08-03T15:55:00')
      redirect_to merchant_campaigns_path
  end
 
  def destroy
    #To-Do: Foretag kald til gateway og aflys udsendelse af sms-er
    @campaign = Campaign.find(params[:id])
    #cancelScheduledOfferReminder?(@campaign)    	
    @campaign.destroy
    flash[:success] = "Kampagne er nu slettet"
    redirect_to merchant_campaigns_path
  end

  def update
    @campaign = Campaign.find(params[:id])    
    @campaign.update_attributes(params[:campaign])
    #reschduleOfferReminder?(@campaign)
    flash[:success] = "Kampagne er blevet opdateret"

    redirect_to [:merchant, @campaign]
  end

end
