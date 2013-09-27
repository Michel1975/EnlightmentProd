class Shared::UsersController < Shared::BaseController
	def new
  		@user = User.new
	end

	def create
  		@user = User.new(params[:user])
  		if @user.save
    		redirect_to root_url, :notice => "Du er nu registreret som medlem!"
  		else
    		render :new
  		end
	end
end
