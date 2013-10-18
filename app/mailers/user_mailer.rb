class UserMailer < ActionMailer::Base
  default sender: "michel@clubnovus.dk"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #

  def reset_password_email(user)
    @user = user
    if user.sub_type == 'MerchantUser'
        @merchant_user = MerchantUser.find(user.sub_id)
        @url  = edit_shared_password_reset_url(user.reset_password_token)
        mail(:to => user.email,
          :subject => t(:password_reset, :scope => [:business_messages, :email]) )
    end
  end

end#end mailer namespace
