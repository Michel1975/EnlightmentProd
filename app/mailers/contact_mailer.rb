class ContactMailer < ActionMailer::Base
  default sender: "michel@clubnovus.dk"
  
  def forward_incoming_mail(message, email, name)
  	@name = name
  	@message = message
  	@email = email
  	mail(to: 'michelhansen75@hotmail.com', subject: t(:forward_incoming_email, :scope => [:business_messages, :email]) )  	
  end
 
  def welcome_mail_new_member(message, email, name)
  	@name = name
  	@message = message
  	@email = email
  	mail(to: @email, subject: t(:confirm_incoming_email, :scope => [:business_messages, :email]) )  	
  end

end
