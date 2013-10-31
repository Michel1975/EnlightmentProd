class Merchant::OffersController < Merchant::BaseController
  #If-override-from-base: layout "merchant", except: [:index]

  def active
    @active_offers = current_merchant_store.offers.where(":date_now >= valid_from AND :date_now <= valid_to",
      {:date_now => Time.zone.now }).paginate(page: params[:page], :per_page => 20)
  end

  def archived
     @inactive_offers = current_merchant_store.offers.where("valid_to < ?", Time.zone.now).paginate(page: params[:page], :per_page => 20)
  end

  def index 
  end

  def show
    @offer = current_resource
  end

  
  def new
    @offer = Offer.new
    @offer.build_image()
  end
  
  def edit
    @offer = current_resource
    if @offer.image.nil?
      @offer.build_image()
    end
  end

  def create
  	@offer = current_merchant_store.offers.build(params[:offer])
    respond_to do |format|
      if @offer.save 
        format.html { redirect_to [:merchant, @offer], notice: t(:offer_created, :scope => [:business_validations, :offer]) }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @offer = current_resource
    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        format.html { redirect_to [:merchant, @offer], notice: t(:offer_updated, :scope => [:business_validations, :offer]) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @offer = current_resource
    @offer.destroy

    respond_to do |format|
      format.html { redirect_to active_merchant_offers_url, notice: t(:offer_deleted, :scope => [:business_validations, :offer]) }
    end
  end


private
  
  def current_resource
    @current_resource ||= Offer.find(params[:id]) if params[:id]
  end
end


=begin
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
    @offer = current_resource

    picture = params[:offer][:offer_picture]
    if picture.present? 
      preloaded = Cloudinary::PreloadedFile.new(picture)
      raise "Invalid upload signature" if !preloaded.valid?
      #Determine if existing picture is beng overwritten. In that case, existing picture on server must be manually deleted.
      if picture != @offer.offer_picture
        #New picture present
        @offer.remove_offer_picture!
      end
      @offer.offer_picture = preloaded.identifier
    end

    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        format.html { redirect_to [:merchant, @offer], notice: t(:offer_updated, :scope => [:business_validations, :offer]) }
      else
        format.html { render action: "edit" }
      end
    end
  end
  
=end