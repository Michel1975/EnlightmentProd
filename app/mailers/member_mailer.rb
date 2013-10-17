class MemberMailer < ActionMailer::Base
  default sender: "michel@clubnovus.dk"
  
  #This template is for new members created on web
  def welcome_mail_new_member(member)
  	@member = member
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: member.user.email, subject:"Velkommen som nyt medlem i Club Novus")  	
  end

  #This template is for sign-ups on web. This template does not include any welcome present - non-eligble members
  def web_sign_up(member, merchant_store)
  	@member = member
  	@merchant_store = merchant_store
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: member.user.email, subject:"Tilmelding til #{@merchant_store.store_name}")  	
  end

  #This template is for sign-ups on web
  def web_opt_out(member, merchant_store)
  	@member = member
  	@merchant_store = merchant_store
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: member.user.email, subject:"Bekraeftelse på din afmelding til #{@merchant_store.store_name}")  	
  end

  #This template is for sign-ups on web
  def web_sign_up_present(member, merchant_store)
  	@member = member
  	@merchant_store = merchant_store
  	#attachments["rails.png"] = File.read("#{Rails.root}/public/404.html")
  	#Se også inline attachments
  	mail(to: member.user.email, subject:"Din velkomstgave fra #{@merchant_store.store_name}")  	
  end


end
