class Merchant::MerchantUsersController < Merchant::BaseController
	def show
		logger.info "Loading MerchantUser show action"
		@merchant_user = current_resource
		logger.debug "Merchant user attributes hash: #{@merchant_user.attributes.inspect}"
	end

	def edit
		logger.info "Loading MerchantUser edit action"
		@merchant_user = current_resource
		logger.debug "Merchant user attributes hash: #{@merchant_user.attributes.inspect}"
	end

	def update
		logger.info "Loading MerchantUser update action"
		@merchant_user = current_resource
		logger.debug "Merchant user attributes hash: #{@merchant_user.attributes.inspect}"
    	if @merchant_user.update_attributes(params[:merchant_user])
    		logger.debug "Merchant user saved successfully: #{@merchant_user.attributes.inspect}"
      		flash[:success] = t(:profile_updated, :scope => [:business_validations, :merchant_user])
      		redirect_to [:merchant, @merchant_user]
    	else
    		logger.debug "Validation errors. Loading edit view with errors"
      		render 'edit'
    	end
	end

	private
  		def current_resource
    		@current_resource ||= MerchantUser.find(params[:id]) if params[:id]
  		end	
end
