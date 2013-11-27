class Admin::MerchantUsersController < Admin::BaseController

	def new
		logger.info "Loading MerchantUser new action"
		logger.debug "Building new merchant user object with user association"
    @merchant_user = MerchantUser.new
  	@merchant_user.build_user()	

    @merchant_store = MerchantStore.find(params[:merchant_store_id])
    logger.debug "Merchant_store - attributes hash: #{@merchant_store.attributes.inspect}"
	end

	def create
		logger.info "Loading MerchantUser create action"
    logger.debug "Building new empty Merchant user record from params"
  	@merchant_user = MerchantUser.new(params[:merchant_user])
  	logger.debug "Merchant user  - attributes hash unsaved: #{@merchant_user.attributes.inspect}"

    @merchant_store = MerchantStore.find(params[:merchant_store_id])
    logger.debug "Merchant_store - attributes hash: #{@merchant_store.attributes.inspect}"
    respond_to do |format|
      if @merchant_user.save
        @merchant_store.merchant_users << @merchant_user
    		logger.debug "Merchant user saved successfully: #{@merchant_user.attributes.inspect}"
    		logger.debug "Sending welcome email to store user with login information..."
    		UserMailer.welcome_merchant_user(@merchant_user.id).deliver
    		format.html { 
    			flash[:success] = t(:profile_created, :scope => [:business_validations, :backend, :merchant_user])
    			redirect_to [:admin,  @merchant_store, @merchant_user]
    		}
  		else
    		logger.debug "Validation errors. Loading new view with errors"
    		format.html { render action: "new" }
  		end
  	end
  end

  def show
  	logger.info "Loading MerchantUser show action"
	  @merchant_user = current_resource	
    logger.debug "Merchant user - attributes hash: #{@merchant_user.attributes.inspect}"
    @merchant_store = MerchantStore.find(params[:merchant_store_id])
    logger.debug "Merchant_store - attributes hash: #{@merchant_store.attributes.inspect}"
  end

  def edit
  	logger.info "Loading MerchantUser edit action"
	  @merchant_user = current_resource	
	  logger.debug "Merchant user - attributes hash: #{@merchant_user.attributes.inspect}"
    @merchant_store = MerchantStore.find(params[:merchant_store_id])
    logger.debug "Merchant_store - attributes hash: #{@merchant_store.attributes.inspect}"
  end

	def update
		logger.info "Loading MerchantUser update action"
		@merchant_user = current_resource
    @merchant_store = MerchantStore.find(params[:merchant_store_id])
    logger.debug "Merchant_store - attributes hash: #{@merchant_store.attributes.inspect}"

		logger.debug "Merchant user attributes hash: #{@merchant_user.attributes.inspect}"
  	if @merchant_user.update_attributes(params[:merchant_user])
  		logger.debug "Merchant user saved successfully: #{@merchant_user.attributes.inspect}"
    	flash[:success] = t(:profile_updated, :scope => [:business_validations, :backend, :merchant_user])
    	redirect_to [:admin, @merchant_store, @merchant_user]
  	else
  		logger.debug "Validation errors. Loading edit view with errors"
    	render 'edit'
  	end
	end

	def destroy
		logger.info "Loading MerchantUser destroy action"
		@merchant_user = current_resource
		@merchant_store = MerchantStore.find(params[:merchant_store_id])
    logger.debug "Merchant_store - attributes hash: #{@merchant_store.attributes.inspect}"

  	logger.debug "Merchant user  - attributes hash: #{@merchant_user.attributes.inspect}"
  	@merchant_user.destroy
  	logger.debug "Merchant user deleted"
  	respond_to do |format|
    		format.html { 
    			flash[:success] = t(:profile_deleted, :scope => [:business_validations, :backend, :merchant_user])
    			redirect_to admin_merchant_store_path(@merchant_store)
    		}
  	end	
	end

	private
  		def current_resource
    		@current_resource ||= MerchantUser.find(params[:id]) if params[:id]
  		end	
end#End merchant_user controller class
