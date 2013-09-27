class Merchant::OffersController < Merchant::BaseController
  before_filter :require_login #man skal være merchantuser
  layout :determine_layout

  def index    
    @active_offers = current_merchant_store.offers.where(":date_now >= valid_from AND :date_now <= valid_to",
      {:date_now => Time.zone.now }).paginate(page: params[:page], :per_page => 20) 
    @inactive_offers = current_merchant_store.offers.where("valid_to < ?", Time.zone.now).paginate(page: params[:page], :per_page => 20)   
  end

  def show
    @offer = Offer.find(params[:id])
  end

  
  def new
    @offer = Offer.new
  end
  
  def edit
    @offer = Offer.find(params[:id])
  end

  def create
  	@offer = current_merchant_store.offers.build(params[:offer])
    respond_to do |format|
      if @offer.save
        format.html { redirect_to [:merchant, @offer], notice: 'Tilbud er blevet oprettet.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @offer = Offer.find(params[:id])

    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        format.html { redirect_to [:merchant, @offer], notice: 'Tilbud er blevet opdateret' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @offer = Offer.find(params[:id])
    @offer.destroy

    respond_to do |format|
      format.html { redirect_to merchant_offers_url }
    end
  end
end