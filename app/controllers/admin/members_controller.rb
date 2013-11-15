class Admin::MembersController < Admin::BaseController
	def active
		logger.info "Loading Members active action"
		@search = false
		logger.debug "Search flag: #{@search.inspect}"
    	@members = Member.where(status: true).page(params[:page]).per_page(15)
    	logger.debug "Members - attributes hash: #{@members.inspect}"
	end

	def inactive
		logger.info "Loading Members inactive action"
    	@members = @members = Member.where(status: false).page(params[:page]).per_page(15)
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
	    logger.debug "Loading active view with search result..."
	    render 'active'
  	end

	def show
		logger.info "Loading Members show action"
		@member = current_resource
		logger.debug "Member - attributes hash: #{@member.attributes.inspect}"
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

	def destroy
		logger.info "Loading Members destroy action"
  		subscriber = current_resource
  		logger.debug "Subscriber - attributes hash: #{subscriber.attributes.inspect}"
		subscriber.opt_out
		if subscriber.save!
			logger.debug "Subscriber status changed successfully to inactive - attributes hash: #{subscriber.attributes.inspect}"
			flash[:success] = t(:subscriber_removed, :scope => [:business_validations, :subscriber])
    		redirect_to merchant_subscribers_url
		else
			logger.debug "Error when updating subscriber status. Redirecting to subscribers list"
			flash[:error] = t(:subscriber_remove_error, :scope => [:business_validations, :subscriber])
    		redirect_to merchant_subscribers_url
		end
	end

	private
    	def current_resource
      		@current_resource ||= Member.find(params[:id]) if params[:id]
    	end

end
