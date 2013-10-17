class MemberUsersController < ApplicationController
  #default layout application is used
	skip_before_filter :require_login, :only => [:new, :create, :complete_sms_profile, :update_sms_profile]
  before_filter :member_user,  :only => [:edit, :update, :show, :destroy]
  
  	#Vigtig! http://apidock.com/rails/ActionView/Helpers/FormHelper/fields_for
  	#Create new member frontend

	def new
		#Fik en fejl på date_select efter vi skiftede til dansk locale
		#Læs denne artikel: http://i18n.lighthouseapp.com/projects/14947/tickets/12-i18n-and-date_select-exception
  		@member = Member.new
  		@member.build_user()

	end

  	#Create new member frontend
  	def create
		#Af en eller anden grund skal man anvende user_attributes i fields_for i formularen til nyt medlem
		#link: http://stackoverflow.com/questions/10701662/rails-cant-mass-assign-protected-attributes-error-when-using-accepts-nested-att
		#Husk at bygge tilknyttede objekter ved oprettelse:http://stackoverflow.com/questions/4729672/accepts-nested-attributes-for-keeps-form-fields-from-showing
  		@member = Member.new(params[:member])
      @member.origin = 'web'
  		if @member.save
  			#virker ikke helt efter hensigten: auto_login(@member.user)
        #Send welcome e-mail
        MemberMailer.welcome_mail_new_member(@member).deliver
    		redirect_to root_path, :notice => t(:member_created, :scope => [:business_validations, :frontend, :member_user])
  		else
    		render :new
  		end
   end

  def edit
  	#logger.info("Michel:" + current_member_user.id + "current_user-id:" + current_user.id)
  	@member = current_member_user
  end

  def show
  	@member_user = current_member_user	
  end

  def update
  	@member_user = Member.find(params[:id])
    if @member_user.update_attributes(params[:member])
    	flash[:success] = t(:member_updated, :scope => [:business_validations, :frontend, :member_user])
    	redirect_to member_user_path(@member_user)
    else
    	render 'edit'
    end
  end

  def destroy
    @member_user = Member.find(params[:id])
    @member_user.destroy
    logout
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  #Show form for completing profile on web
  #Eksempel: http://localhost:3000/edit_sms_profile/0f4882b68a
  def complete_sms_profile
    token = params[:token]
    if token.present?
      @member = Member.find_by_access_key(params[:token])
      if @member.nil?
        flash[:alert] = t(:member_not_exist, :scope => [:business_messages, :web_profile])
        redirect_to root_path
      elsif @member.complete
        flash[:alert] = t(:already_finished, :scope => [:business_messages, :web_profile])
        redirect_to root_path
      else
        #Set validation mode and build user object
        @member.validation_mode = "web"
        @member.build_user()
      end
    else
      flash[:alert] = t(:security_error, :scope => [:business_messages, :web_profile])
      redirect_to root_path
    end
  end

  #Save full profile with all attributes
  def update_sms_profile 
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member])
        flash[:notice] = t(:success, :scope => [:business_messages, :web_profile])
        #Overvej at linke direkte til butikken efter profilen er færdig oprettet.
        redirect_to root_path
    else
      render 'complete_sms_profile'      
    end
  end

end
