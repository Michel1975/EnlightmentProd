class Shared::PasswordResetsController < Shared::BaseController
  skip_before_filter :require_login
    
  # request password reset.
  # you get here when the user entered his email in the reset password form and submitted it.
  def create 
    logger.info "Loading PasswordReset create action"
    @user = User.find_by_email(params[:email])
    logger.debug "User attributes hash: #{@user.attributes.inspect}"
        
    # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
    @user.deliver_reset_password_instructions! if @user
    logger.debug "Reset email sent to user with instructions"
        
    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.
    flash[:success] = t(:email_sent, :scope => [:business_validations, :password_reset])
    redirect_to root_path
  end
    
  #This is the reset password form.
  def edit
    logger.info "Loading PasswordReset edit action"
    @user = User.load_from_reset_password_token(params[:id])
    if @user.present?
      logger.debug "User attributes hash: #{@user.attributes.inspect}" 
      @token = params[:id]
      logger.debug "Token: #{@token.inspect}"
      #We use password resets for initializing password to new merchant users, so the view needs a little tweak to distinguish the different cases.
      @merchant_user = @user.sub_type == "MerchantUser" ? true : false
      logger.debug "Merchant user?: #{@merchant_user.inspect}"
    else
      flash[:error] = t(:password_invalid_request, :scope => [:business_validations, :password_reset])
      redirect_to root_path
    end
  end
      
  #This action fires when the user has sent the reset password form.
  def update
    logger.info "Loading PasswordReset update action"
    @token = params[:token]
    logger.debug "Token: #{@token.inspect}"
    @user = User.load_from_reset_password_token(params[:token])
    not_authenticated and return unless @user
    logger.debug "User attributes hash: #{@user.attributes.inspect}"
    @merchant_user = @user.sub_type == "MerchantUser" ? true : false
    logger.debug "Merchant user?: #{@merchant_user.inspect}"
    
    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password!(params[:user][:password])
      if @merchant_user == true
        logger.debug "New password created for merchant user"
        flash[:success] = t(:new_password_created, :scope => [:business_validations, :merchant_user])
        redirect_to root_path
      else
        logger.debug "Password reset completed successfully"
        flash[:success] = t(:password_reset_confirmation, :scope => [:business_validations, :password_reset])
        redirect_to root_path
      end
    else
      logger.debug "Validation errors. Loading edit view with errors"
      render :action => "edit"
    end
  end
end
