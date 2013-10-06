class Merchant::OffersController < Merchant::BaseController
  #If-override-from-base: layout "merchant", except: [:index]
  
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
    #File handling
    if params[:offer][:offer_picture].present? 
      preloaded = Cloudinary::PreloadedFile.new(params[:offer][:offer_picture])         
      raise "Invalid upload signature" if !preloaded.valid?
      @offer.offer_picture = preloaded.identifier
    end

    respond_to do |format|
      if @offer.save 
        format.html { redirect_to [:merchant, @offer], notice: t(:offer_created, :scope => [:business_validations, :offer]) }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @offer = Offer.find(params[:id])

    if params[:offer][:offer_picture].present? 
      preloaded = Cloudinary::PreloadedFile.new(params[:offer][:offer_picture])         
      raise "Invalid upload signature" if !preloaded.valid?
      @offer.offer_picture = preloaded.identifier
    else
       @offer.offer_picture = nil
    end

    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        format.html { redirect_to [:merchant, @offer], notice: t(:offer_updated, :scope => [:business_validations, :offer]) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @offer = Offer.find(params[:id])
    @offer.destroy

    respond_to do |format|
      format.html { redirect_to merchant_offers_url, notice: t(:offer_deleted, :scope => [:business_validations, :offer]) }
    end
  end
end