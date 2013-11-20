class Admin::MembersController < Admin::BaseController
	def index
		logger.info "Loading Members index action"
		@search = false
		logger.debug "Search flag: #{@search.inspect}"
    	@members = Member.where(status: true).page(params[:page]).per_page(15)
    	logger.debug "Members - attributes hash: #{@members.inspect}"
	end

	def search_members
	    logger.info "Loading Members search_members action"
	    @name = params[:name]
	    logger.debug "Search parameter - name: #{@name.inspect}"
	    @search = true
	    logger.debug "Search flag: #{@search.inspect}"
	    @members = Member.search(@name).page( params[:page] ).per_page(15)
	    logger.debug "Search result: #{@members.inspect}"
	    logger.debug "Loading index view with search result..."
	    render 'index'
  	end

	def show
		logger.info "Loading Members show action"
		@member = current_resource
		logger.debug "Member - attributes hash: #{@member.attributes.inspect}"

		@subscriber_stores = @member.subscribers.active.page( params[:page] ).per_page(15)
		logger.debug "Subscriber stores - attributes hash: #{@subscriber_stores.inspect}"
	end

	def edit
		logger.info "Loading Members edit action"
  		#logger.info("Michel:" + current_member_user.id + "current_user-id:" + current_user.id)
  		@member_user = current_resource #Old:current_member_user
    	logger.debug "Member attributes hash: #{@member_user.attributes.inspect}"
	end

	def update
		logger.info "Loading Members update action"
  		@member_user = current_resource
    	logger.debug "Member attributes hash: #{@member_user.attributes.inspect}" 
    	
    	if @member_user.update_attributes(params[:member])
      		logger.debug "Member updated succesfully - attributes hash: #{@member_user.attributes.inspect}" 
    		flash[:success] = t(:member_updated, :scope => [:business_validations, :frontend, :member_user])
    		redirect_to member_user_path(@member_user)
    	else
      		logger.debug "Validation errors. Loading edit view with errors"
    		render 'edit'
    	end
	end

	def remove_subscriber
		logger.info "Loading Members remove_subscriber action"
  		subscriber = Subscriber.find(params[:id])
  		logger.debug "Subscriber - attributes hash: #{subscriber.attributes.inspect}"
  		member = Member.find(subscriber.member_id)
  		logger.debug "Member - attributes hash: #{member.attributes.inspect}"
		if subscriber.destroy
			logger.debug "Subscriber deleted successfully"
			flash[:success] = t(:subscriber_removed, :scope => [:business_validations, :subscriber])
    		redirect_to [:admin, member]
		else
			logger.debug "Error when deleting subscriber"
			logger.fatal "Error when deleting subscriber"
			flash[:error] = t(:subscriber_remove_error, :scope => [:business_validations, :subscriber])
    		redirect_to [:admin, member]
		end
	end

	def destroy
		logger.info "Loading Members destroy action"
  		member = current_resource
  		logger.debug "Member - attributes hash: #{member.attributes.inspect}"
		if member.destroy
			logger.debug "Member successfully deleted"
			flash[:success] = t(:member_removed, :scope => [:business_validations, :subscriber])
    		redirect_to admin_members_path
		else
			logger.debug "Error deleting member. Redirecting to member list"
			logger.fatal "Error deleting member. Redirecting to member list"
			flash[:error] = t(:member_remove_error, :scope => [:business_validations, :subscriber])
    		redirect_to admin_members_path
		end
	end

	private
    	def current_resource
      		@current_resource ||= Member.find(params[:id]) if params[:id]
    	end

end
