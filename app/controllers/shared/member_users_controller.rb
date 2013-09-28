class Shared::MemberUsersController < Shared::BaseController
  #Vigtig! http://apidock.com/rails/ActionView/Helpers/FormHelper/fields_for
  #Create new member frontend
  def new
  		@member = Member.new
	end

  #Create new member frontend
	def create
		#Af en eller anden grund skal man anvende user_attributes i fields_for i formularen til nyt medlem
		#link: http://stackoverflow.com/questions/10701662/rails-cant-mass-assign-protected-attributes-error-when-using-accepts-nested-att
		#Husk at bygge tilknyttede objekter ved oprettelse:http://stackoverflow.com/questions/4729672/accepts-nested-attributes-for-keeps-form-fields-from-showing
  		@member = Member.new(params[:member])
  		if @member.save
    		redirect_to root_url, :notice => "Du er nu registreret som medlem!"
  		else
    		render :new
  		end
	end

  def edit
  end

  def update
  end
  
end
