class Merchant::OffersController < Merchant::BaseController

  #Test: OK
  def active
    logger.info "Loading Offers active action"
    @active_offers = current_merchant_store.offers.where(":date_now >= valid_from AND :date_now <= valid_to",
      {:date_now => Time.zone.now }).page(params[:page]).per_page(10)
    logger.debug "Active offers - attributes hash: #{@active_offers.inspect}"
  end

  #Test:OK
  def archived
    logger.info "Loading Offers archived action"
    @inactive_offers = current_merchant_store.offers.where("valid_to < ?", Time.zone.now).page(params[:page]).per_page(10)
    logger.debug "Archived offers - attributes hash: #{@inactive_offers.inspect}"
  end

  def index 
  end

  #Test:OK
  def show
    logger.info "Loading Offers show action"
    @offer = current_resource
    logger.debug "Offer - attributes hash: #{@offer.attributes.inspect}"
  end

  #Test:OK
  def new
    logger.info "Loading Offers new action"
    @offer = Offer.new
    @offer.build_image()
    logger.debug "New offer - attributes hash: #{@offer.attributes.inspect}"
  end
  
  #Test:OK
  def edit
    logger.info "Loading Offers edit action"
    @offer = current_resource
    logger.debug "Offer - attributes hash: #{@offer.attributes.inspect}"
    if @offer.image.nil?
      logger.debug "No image record present. Building new image"
      @offer.build_image()
    end
  end

  #Test:OK
  def create
    logger.info "Loading Offers create action"
    logger.debug "Building new empty offer record"
  	@offer = current_merchant_store.offers.build(params[:offer])
    if @offer.save
      logger.debug "Offer saved successfully: #{@offer.attributes.inspect}"
      flash[:success] = t(:offer_created, :scope => [:business_validations, :offer])
      redirect_to [:merchant, @offer]
    else
      logger.debug "Validation errors. Loading new view with errors"
      render :new
    end
  end

  #Test:OK
  def update
    logger.info "Loading Offers update action"
    @offer = current_resource
    logger.debug "Offer - attributes hash: #{@offer.attributes.inspect}"
    if @offer.update_attributes(params[:offer])
      logger.debug "Offer updated successfully: #{@offer.attributes.inspect}"
      flash[:success] = t(:offer_updated, :scope => [:business_validations, :offer] )
      redirect_to [:merchant, @offer]
    else
      logger.debug "Validation errors. Loading edit view with errors"
      render :edit
    end
  end

  #Test:OK
  def destroy
    logger.info "Loading Offers destroy action"
    @offer = current_resource
    logger.debug "Offer - attributes hash: #{@offer.attributes.inspect}"
    if @offer.destroy
      logger.debug "Offer deleted successfully"
      flash[:success] = t(:offer_deleted, :scope => [:business_validations, :offer])
      redirect_to active_merchant_offers_url
    else
      logger.debug "Error: Offer NOT deleted due to unknown error"
      logger.fatal "Error: Offer NOT deleted due to unknown error"
      flash[:error] = t(:offer_delete_error, :scope => [:business_validations, :offer])
      redirect_to active_merchant_offers_url
    end
  end

private
  
  def current_resource
    @current_resource ||= Offer.find(params[:id]) if params[:id]
  end
end
