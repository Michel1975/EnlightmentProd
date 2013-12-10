class UserMailer < ActionMailer::Base
  default from: "michel@clubnovus.dk"
  

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    host_state = ENV['TEST_STAGE'] == 'true' ? 'test.clubnovus.dk' : 'clubnovus.dk'
    @user_name = ""
    if user.sub_type == 'MerchantUser'
      @merchant_user = MerchantUser.find(user.sub_id)
      @user_name = @merchant_user.name
      #Host me specified explicit since controller context is missing
      @url  = edit_shared_password_reset_url(user.reset_password_token, host: host_state)
      mail(:to => user.email,
        :subject => t(:password_reset, :scope => [:business_messages, :email]) )
    elsif
      user.sub_type == 'Member'
      @member_user = Member.find(user.sub_id)
      @user_name = @member_user.name
      @url  = edit_shared_password_reset_url(user.reset_password_token, host: host_state)
      mail(:to => user.email,
      :subject => t(:password_reset, :scope => [:business_messages, :email]) )
    end
  end
  
  #Only for merchant users
  def welcome_merchant_user(merchant_user)
    host_state = ENV['TEST_STAGE'] == 'true' ? 'test.clubnovus.dk' : 'clubnovus.dk'
    Rails.logger.info "Into UserMailer welcome_merchant_user method"
    @merchant_user = MerchantUser.find(merchant_user)
    if @merchant_user.present?
      Rails.logger.debug "Merchant user attributes hash: #{@merchant_user.attributes.inspect}"
      #Host me specified explicit since controller context is missing
      @url = edit_shared_password_reset_url(@merchant_user.user.reset_password_token, host: host_state)
      Rails.logger.debug "Password reset url: #{@url.inspect}"
      Rails.logger.debug "Merchant user present - sending email"
      mail(:to => @merchant_user.user.email,
          :subject => t(:welcome_merchant_user, :scope => [:business_messages, :merchant_user]) )
    else
      Rails.logger.debug "Could not find merchant user. Welcome email not sent" 
      Rails.logger.fatal "Could not find merchant user. Welcome email not sent" 
    end
  end

end#end mailer namespace
