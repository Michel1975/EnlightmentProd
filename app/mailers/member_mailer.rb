class MemberMailer < ActionMailer::Base
  default sender: "michel@clubnovus.dk"
  
  #This template is for new members created on web
  def welcome_mail_new_member(member)
  	@member = member
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: member.user.email, subject: t(:welcome_mail_new_member, :scope => [:business_messages, :email]) )  	
  end

  #This template is for sign-ups on web. This template does not include any welcome present - non-eligble members
  def web_sign_up(member, merchant_store)
  	@member = member
  	@merchant_store = merchant_store
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: member.user.email, subject: t(:web_sign_up, store_name: merchant_store.store_name, :scope => [:business_messages, :email]) )  	
  end

  #This template is for sign-ups on web
  def web_opt_out(member, merchant_store)
  	@member = member
  	@merchant_store = merchant_store
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: member.user.email, subject: t(:web_opt_out, store_name: merchant_store.store_name, :scope => [:business_messages, :email]) )  	
  end

  #This template is for sign-ups on web
  def web_sign_up_present(member, merchant_store)
  	@member = member
  	@merchant_store = merchant_store
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: member.user.email, subject: t(:web_sign_up_present, store_name: merchant_store.store_name, :scope => [:business_messages, :email]) )  	
  end


end
