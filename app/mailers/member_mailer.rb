class MemberMailer < ActionMailer::Base
  default from: "michel@clubnovus.dk"
  
  #This template is for new members created on web. This email includes email confirmation link
  def welcome_mail_new_member(member)
  	@member = Member.find(member)
    #Insert unique confirm link
    @url = @member.confirm_email_link
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: @member.user.email, subject: t(:welcome_mail_new_member, :scope => [:business_messages, :email]) )  	
  end

  #This template is used for re-sending confirmation emails
  def email_confirmation_link(member)
    @member = Member.find(member)
    @url = @member.confirm_email_link
    #attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
    #Se også inline attachments
    mail(to: @member.user.email, subject: t(:email_confirmation, :scope => [:business_messages, :email]) )   
  end

  #This template is for sign-ups on web. This template does not include any welcome present - non-eligble members
  def web_sign_up(member, merchant_store)
  	@member = Member.find(member)
  	@merchant_store = MerchantStore.find(merchant_store)
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: @member.user.email, subject: t(:web_sign_up, store_name: @merchant_store.store_name, :scope => [:business_messages, :email]) )  	
  end

  #This template is for sign-ups on web
  def web_opt_out(member, merchant_store)
  	@member = Member.find(member)
  	@merchant_store = MerchantStore.find(merchant_store)
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: @member.user.email, subject: t(:web_opt_out, store_name: @merchant_store.store_name, :scope => [:business_messages, :email]) )  	
  end

  #This template is for sign-ups on web
  def web_sign_up_present(member, merchant_store)
  	@member = Member.find(member)
    @merchant_store = MerchantStore.find(merchant_store)
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: @member.user.email, subject: t(:web_sign_up_present, store_name: @merchant_store.store_name, :scope => [:business_messages, :email]) )  	
  end

end
