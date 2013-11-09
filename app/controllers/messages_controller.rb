class MessagesController < ApplicationController
	skip_before_filter :require_login
	skip_before_filter :authorize
	
	def contact
	end

	def send_message
		email = params[:email]
		name = params[:name]
		message = params[:message]
		if email.present? && name.present? && message.present?
			ContactMailer.delay.forward_incoming_mail(message, email, name)
			ContactMailer.delay.welcome_mail_new_member(message, email, name)
			redirect_to root_path, :success => t(:confirm_incoming_web, :scope => [:business_messages,  :email])
		else
			flash[:alert] = t(:invalid_contact_data, :scope => [:business_messages, :email])
			render 'send_message'
		end
	end

end
