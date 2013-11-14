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
    redirect_to(root_path, :success => t(:email_sent, :scope => [:business_validations, :password_reset]))
  end
    
  # This is the reset password form.
  def edit
    logger.info "Loading PasswordReset edit action"
    @user = User.load_from_reset_password_token(params[:id])
    logger.debug "User attributes hash: #{@user.attributes.inspect}"
    @token = params[:id]
    logger.debug "Token: #{@token.inspect}"
    not_authenticated unless @user
  end
      
  # This action fires when the user has sent the reset password form.
  def update
    logger.info "Loading PasswordReset update action"
    @token = params[:token]
    logger.debug "Token: #{@token.inspect}"
    @user = User.load_from_reset_password_token(params[:token])
    logger.debug "User attributes hash: #{@user.attributes.inspect}"
    not_authenticated and return unless @user
    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password!(params[:user][:password])
      logger.debug "Password reset completed successfully"
      redirect_to(root_path, :success => t(:password_reset_confirmation, :scope => [:business_validations, :password_reset]))
    else
      logger.debug "Validation errors. Loading edit view with errors"
      render :action => "edit"
    end
  end
end
