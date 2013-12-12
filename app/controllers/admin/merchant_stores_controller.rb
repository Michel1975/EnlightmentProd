#encoding: utf-8
class Admin::MerchantStoresController < Admin::BaseController

	#Test: OK
	def active
		logger.info "Loading MerchantStores active action"
		logger.debug "Resetting search params if they exist...."
    	params[:store_name].delete if params[:store_name]
    	params[:city].delete if params[:city]
		
		@search = false
		logger.debug "Search flag: #{@search.inspect}"
		
		@merchant_stores = MerchantStore.where(active: true).page(params[:page]).per_page(15)
		logger.debug "Merchant-stores attributes hash: #{@merchant_stores.inspect}"
	end

	#Test: OK
	def inactive
		logger.info "Loading MerchantStores inactive action"
		@merchant_stores = MerchantStore.where(active: false).page(params[:page]).per_page(15)
		logger.debug "Merchant-stores attributes hash: #{@merchant_stores.inspect}"
	end

	#Test: OK
	def search_stores
	    logger.info "Loading MerchantStores search_stores action"
	    @city = params[:city]
	    logger.debug "Search parameter - city: #{@city.inspect}"
	    @store_name = params[:store_name]
	    logger.debug "Search parameter - store-name: #{@store_name.inspect}"
	    @merchant_stores = MerchantStore.search(@city, @store_name).page(params[:page]).per_page(15)
	    logger.debug "Merchant-stores attributes hash: #{@merchant_stores.inspect}"

	    @search = true
	    logger.debug "Search flag: #{@search.inspect}"

	    logger.debug "Loading active view with search result..."
	    render 'active'
	end

	#Test: OK
	def new
		logger.info "Loading MerchantStore new action"
		@merchant_store = MerchantStore.new
		@merchant_store.build_image()
		@merchant_store.build_qr_image()
		logger.debug "MerchantStore initialized for form - attributes hash: #{@merchant_store.attributes.inspect}"
		logger.debug "MerchantStore business hours - attributes hash: #{@merchant_store.business_hours.inspect}"
	end

	#Test: OK
	def create
		logger.info "Loading MerchantStore create action"
		logger.debug "Building new empty merchant_store record"
		@merchant_store = MerchantStore.new(params[:merchant_store])
		logger.debug "Inserting country into record"
		
		#Need to manually insert country
		@merchant_store.country = 'Denmark'
		logger.debug "MerchantStore initialized - attributes hash: #{@merchant_store.attributes.inspect}"
		
	  	if @merchant_store.save
	  		logger.debug "MerchantStore created successfully: #{@merchant_store.attributes.inspect}"
	  		logger.debug "Proceeding with default subscription..."
	  		#Create default subscription to store. Currently we only choose basic subscription as default choice
	  		subscription_type = SubscriptionType.find_by_name("Test medlemskab")
	  		logger.debug "Basic subscription type lookup: #{subscription_type.attributes.inspect}"
	  		@merchant_store.create_subscription_plan(start_date: Time.now, subscription_type_id: subscription_type.id)
	  		logger.debug "Successfully created default basic subscription for store"

	  		#Create default welcome offer
  			@merchant_store.create_welcome_offer!(description: 'Spørg i butikken', active: true)
  			logger.debug "Successfully created default welcome offer for store"
	    	flash[:success] = t(:store_created, :scope => [:business_validations, :backend, :store])
	    	redirect_to [:admin, @merchant_store] 
	  	else
	    	logger.debug "Validation errors. Loading new view with errors"
	    	render :new
	  	end
	end

	#Test: OK
	def edit
		logger.info "Loading MerchantStore edit action"
	    @merchant_store = current_resource
	    logger.debug "MerchantStore attributes hash: #{@merchant_store.attributes.inspect}"
	    if @merchant_store.image.nil?
	      logger.debug "No image detected. Building new image record"
	      @merchant_store.build_image()
	    end
	    if @merchant_store.qr_image.nil?
	      logger.debug "No QR_code detected. Building new image record"
	      @merchant_store.build_qr_image()
	    end
	end

	#Test: OK
	def update
		logger.info "Loading MerchantStore update action"
		@merchant_store = current_resource
		logger.debug "Merchant_store attributes hash: #{@merchant_store.attributes.inspect}"
		if @merchant_store.update_attributes(params[:merchant_store])
		    logger.debug "MerchantStore updated successfully: #{@merchant_store.attributes.inspect}"
		  	flash[:success] = t(:store_updated, :scope => [:business_validations, :backend, :store])        
		  	redirect_to [:admin, @merchant_store]
		else
		    logger.debug "Validation errors. Loading edit view with errors"
		  	render 'edit'
		end
	end

	#Test: OK
	def show
		logger.info "Loading MerchantStore show action"
		@merchant_store = current_resource
		logger.debug "MerchantStore attributes hash: #{@merchant_store.attributes.inspect}"

		#Each store only has one user - for now.
		@merchant_user = @merchant_store.merchant_users.first 
		if @merchant_user.present?
			logger.debug "Loading default merchant user for store - attributes: #{@merchant_user.attributes.inspect}"
		end
	end

	#Test: OK
	def destroy
		logger.info "Loading MerchantStore destroy action"
		logger.info "We don't actually delete stores at this moment. We only deactivate them for now..."
		@merchant_store = current_resource
    	logger.debug "MerchantStore - attributes hash: #{@merchant_store.attributes.inspect}"
  		@merchant_store.active = false
  		if @merchant_store.save
  			logger.debug "MerchantStore deactivated successfully"
			flash[:success] = t(:store_deleted, :scope => [:business_validations, :backend, :store])
			redirect_to active_admin_merchant_stores_path
		else
			logger.debug "Error: Could not deacticate store due to unknown error"
			logger.fatal "Error: Could not deacticate store due to unknown error"
			flash[:error] = t(:store_delete_error, :scope => [:business_validations, :backend, :store])
			redirect_to active_admin_merchant_stores_path	
		end
	end

	#Test: OK
	def login_as
    	logger.info "Loading MerchantStore log_in_as action"
    	@merchant_store = current_resource
    	logger.debug "MerchantStore attributes hash: #{@merchant_store.attributes.inspect}" 

    	logger.debug "Loading default admin_user for Club Novus"
    	user = User.find_by_email('admin_user@clubnovus.dk')
    	if user
    		logger.debug "User attributes hash: #{user.attributes.inspect}" 
      		merchant_user = MerchantUser.find(user.sub_id)
      		if merchant_user
      			logger.debug "MerchantUser attributes hash: #{merchant_user.attributes.inspect}" 
        		merchant_user.login_as(@merchant_store.id)
        		if merchant_user.save
          			flash[:success] = t(:login_as_success, store_name: @merchant_store.store_name, :scope => [:business_validations, :backend, :store])       
          			redirect_to active_admin_merchant_stores_path
          			return
        		end
      		end
    	end
    	#Throw standard error if any error occurs
    	flash[:alert] = t(:login_as_error, :scope => [:business_validations, :backend, :store])       
        redirect_to active_admin_merchant_stores_path
  	end

	private
		def current_resource
  			@current_resource ||= MerchantStore.find(params[:id]) if params[:id]
		end

end#End controller
