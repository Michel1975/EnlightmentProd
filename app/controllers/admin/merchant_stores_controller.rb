class Admin::MerchantStoresController < Admin::BaseController

	def active
		logger.info "Loading MerchantStores active action"
		@search = false
		logger.debug "Search flag: #{@search.inspect}"
    	
    	@merchant_stores = MerchantStore.where(active: true).page(params[:page]).per_page(15)
    	logger.debug "Merchant-stores attributes hash: #{@merchant_stores.inspect}"
	end

	def inactive
		logger.info "Loading MerchantStores inactive action"
    	@merchant_stores = MerchantStore.where(active: false).page(params[:page]).per_page(15)
    	logger.debug "Merchant-stores attributes hash: #{@merchant_stores.inspect}"
	end

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

end#End controller
