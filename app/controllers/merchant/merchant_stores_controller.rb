class Merchant::MerchantStoresController < Merchant::BaseController
  	before_filter :require_login #man skal være merchantuser
	layout :determine_layout
  
  	def new
    	@merchant_store = MerchantStore.new
  	end

  	def create
    	@merchant_store = MerchantStore.new(params[:merchant_store])
    	if @merchant_store.save           
      		flash[:success] = "Butik er nu oprettet!"
      		redirect_to @merchant_store
    	else
      		render 'new'
    	end
  	end

  	def edit
    	@merchant_store = MerchantStore.find(params[:id])
  	end

  	def update
    	@merchant_store = MerchantStore.find(params[:id])
    	if @merchant_store.update_attributes(params[:merchant_store])
      		flash[:success] = "Oplysningerne er nu opdateret"           
      		redirect_to @merchant_store
    	else
      		render 'edit'
    	end
  	end

  	def show
    	@merchant_store = MerchantStore.find(params[:id])
  	end

  	def destroy 
    	MerchantStore.find(params[:id]).destroy
    	flash[:success] = "Butik er nu slettet."
    	redirect_to merchant_stores_url
  	end

  	def index
    	@merchant_stores = MerchantStore.paginate(page: params[:page])
  	end
end
