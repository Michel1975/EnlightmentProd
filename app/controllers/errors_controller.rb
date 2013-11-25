class ErrorsController < ApplicationController
	skip_before_filter :require_login
	skip_before_filter :authorize

	def show
		logger.info "Loading Errors show action - exception has been caught"
		logger.debug "Request path - #{request.path.inspect}"
		@exception = env["action_dispatch.exception"]
		logger.debug "Exception details - #{@exception.inspect}"
        @status_code = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
        logger.debug "Status-code details - #{@status_code.inspect}"
        if @status_code == 404
        	render '404'
        else
        	render 'generic'
        end
	end

end#End class
