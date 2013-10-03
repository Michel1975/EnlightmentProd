class Merchant::MerchantStoresController < Merchant::BaseController
  #If-override-from-base: layout "merchant", except: [:index]
  
  def edit
    @merchant_store = MerchantStore.find(params[:id])
  end

  def update
    @merchant_store = MerchantStore.find(params[:id])
      if @merchant_store.update_attributes(params[:merchant_store])
      		flash[:success] = t(:information_updated, :scope => [:business_validations, :merchant_store])        
      		redirect_to [:merchant, @merchant_store]
    	else
      		render 'edit'
    	end
  	end

  def show
    @merchant_store = MerchantStore.find(params[:id])
  end

  def active_subscription
    @merchant_store = current_merchant_store
    @subscription = @merchant_store.subscription_plan
    @features = @subscription.subscription_type.features
  end

end
