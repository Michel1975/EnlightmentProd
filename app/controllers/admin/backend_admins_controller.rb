class Admin::BackendAdminsController < Admin::BaseController
	#Test: OK
	def show
		logger.info "Loading BackendAdmins show action"
		@backend_admin_user = current_resource
		logger.debug "BackendAdmin user attributes hash: #{@backend_admin_user.attributes.inspect}"
	end

	#Test: OK
	def edit
		logger.info "Loading BackendAdmins edit action"
		@backend_admin_user = current_resource
		logger.debug "BackendAdmin user attributes hash: #{@backend_admin_user.attributes.inspect}"
	end

	#Test: OK
	def update
		logger.info "Loading BackendAdmins update action"
		@backend_admin_user = current_resource
		logger.debug "BackendAdmin user attributes hash: #{@backend_admin_user.attributes.inspect}"
    	if @backend_admin_user.update_attributes(params[:backend_admin])
    		logger.debug "BackendAdmin user saved successfully: #{@backend_admin_user.attributes.inspect}"
      		flash[:success] = t(:profile_updated, :scope => [:business_validations, :backend_admin])
      		redirect_to [:admin, @backend_admin_user]
    	else
    		logger.debug "Validation errors. Loading edit view with errors"
      		render 'edit'
    	end
	end

	private
		def current_resource
			@current_resource ||= BackendAdmin.find(params[:id]) if params[:id]
		end	

end

