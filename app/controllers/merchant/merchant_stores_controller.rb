class Merchant::MerchantStoresController < Merchant::BaseController
  #If-override-from-base: layout "merchant", except: [:index]
  
  def edit
    @merchant_store = MerchantStore.find(params[:id])
  end

  def update
    @merchant_store = MerchantStore.find(params[:id])
    if params[:merchant_store][:store_picture].present? 
      preloaded = Cloudinary::PreloadedFile.new(params[:merchant_store][:store_picture])         
        raise "Invalid upload signature" if !preloaded.valid?
        @merchant_store.store_picture = preloaded.identifier
    else
       @merchant_store.store_picture = nil
    end

      
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
