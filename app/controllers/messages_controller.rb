class MessagesController < ApplicationController
	skip_before_filter :require_login
	skip_before_filter :authorize
	
	def contact
		logger.info "Loading Messages contact action"
	end

	#Forward message from contact form to Club Novus administrator
	def send_message
		logger.info "Loading Message send_message action"
		email = params[:email] 
		logger.debug "Email: #{email.inspect}" if email.present?
		name = params[:name] 
		logger.debug "Name: #{name.inspect}" if name.present?
		message = params[:message]
		logger.debug "Message: #{message.inspect}" if message.present?

		if email.present? && name.present? && message.present?
			logger.debug "All attributes present. Email can be sent."
			ContactMailer.delay.forward_incoming_mail(message, email, name)
			logger.debug "Sending delayed confirmation message to clubnovus admin..."
			ContactMailer.delay.welcome_mail_new_member(message, email, name)
			logger.debug "Sending delayed confirmation message to prospect..."
			redirect_to root_path, :success => t(:confirm_incoming_web, :scope => [:business_messages, :email])
		else
			logger.debug "Validation errors. Loading send_message view with errors"
			flash[:alert] = t(:invalid_contact_data, :scope => [:business_messages, :email])
			render 'send_message'
		end
	end

end
