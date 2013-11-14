class Merchant::OffersController < Merchant::BaseController

  def active
    logger.info "Loading offer active action"
    @active_offers = current_merchant_store.offers.where(":date_now >= valid_from AND :date_now <= valid_to",
      {:date_now => Time.zone.now }).page(params[:page]).per_page(10)
    logger.debug "Active offers - attributes hash: #{@active_offers.inspect}"
  end

  def archived
    logger.info "Loading offer archived action"
    @inactive_offers = current_merchant_store.offers.where("valid_to < ?", Time.zone.now).page(params[:page]).per_page(10)
    logger.debug "Archived offers - attributes hash: #{@inactive_offers.inspect}"
  end

  def index 
  end

  def show
    logger.info "Loading offer show action"
    @offer = current_resource
    logger.debug "Offer - attributes hash: #{@offer.attributes.inspect}"
  end

  
  def new
    logger.info "Loading offer new action"
    @offer = Offer.new
    @offer.build_image()
    logger.debug "New offer - attributes hash: #{@offer.attributes.inspect}"
  end
  
  def edit
    logger.info "Loading offer edit action"
    @offer = current_resource
    logger.debug "Offer - attributes hash: #{@offer.attributes.inspect}"
    if @offer.image.nil?
      logger.debug "No image record present. Building new image"
      @offer.build_image()
    end
  end

  def create
    logger.info "Loading offer create action"
    logger.debug "Building new empty offer record"
  	@offer = current_merchant_store.offers.build(params[:offer])
    respond_to do |format|
      if @offer.save
        logger.debug "Offer saved successfully: #{@offer.attributes.inspect}"
        format.html { redirect_to [:merchant, @offer], :success => t(:offer_created, :scope => [:business_validations, :offer]) }
      else
        logger.debug "Validation errors. Loading new view with errors"
        format.html { render action: "new" }
      end
    end
  end

  def update
    logger.info "Loading offer update action"
    @offer = current_resource
    logger.debug "Offer - attributes hash: #{@offer.attributes.inspect}"
    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        logger.debug "Offer updated successfully: #{@offer.attributes.inspect}"
        format.html { redirect_to [:merchant, @offer], notice: t(:offer_updated, :scope => [:business_validations, :offer]) }
      else
        logger.debug "Validation errors. Loading edit view with errors"
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    logger.info "Loading offer destroy action"
    @offer = current_resource
    logger.debug "Offer - attributes hash: #{@offer.attributes.inspect}"
    @offer.destroy
    logger.debug "Offer deleted"
    respond_to do |format|
      format.html { redirect_to active_merchant_offers_url, notice: t(:offer_deleted, :scope => [:business_validations, :offer]) }
    end
  end


private
  
  def current_resource
    @current_resource ||= Offer.find(params[:id]) if params[:id]
  end
end
