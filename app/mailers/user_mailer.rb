class UserMailer < ActionMailer::Base
  default sender: "michel@clubnovus.dk"
  

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #

  def reset_password_email(user)
    @user_name = ""
    if user.sub_type == 'MerchantUser'
        @merchant_user = MerchantUser.find(user.sub_id)
        @user_name = @merchant_user.name
        @url  = edit_shared_password_reset_url(user.reset_password_token)
        mail(:to => user.email,
          :subject => t(:password_reset, :scope => [:business_messages, :email]) )
    elsif
      user.sub_type == 'Member'
        @member_user = Member.find(user.sub_id)
        @user_name = @member_user.name
        @url  = edit_shared_password_reset_url(user.reset_password_token)
        mail(:to => user.email,
          :subject => t(:password_reset, :scope => [:business_messages, :email]) )
      end
  end
  
  #Only for merchant users
  def welcome_merchant_user(merchant_user)
    @merchant_user = MerchantUser.find(merchant_user)
    if @merchant_user.present? 
        mail(:to => @merchant_user.user.email,
          :subject => t(:welcome_merchant_user, :scope => [:business_messages, :merchant_user]) )
    end
  end

end#end mailer namespace
