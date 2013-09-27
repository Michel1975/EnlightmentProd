class Shared::MembersController < Shared::BaseController
	before_filter :require_login, 
	layout :determine_layout

	def new_manual_subscriber
		@member = Member.new
	end

	def create_manual_subscriber
		@member = Member.find_by_phone(params[:member][:phone])
		if @member 
			current_merchant_store.subscribers.build!(start_date: Date.today, member_id: @member.id )
		else
			@member = Member.new(params[:member])
		end
		respond_to do |format|
		if @member.save
        	format.html { redirect_to merchant_subscriber_path(@member), notice: 'Medlem er blevet oprettet.' }
      	else
        	format.html { render action: "create_manual_subscriber" }
      	end
    end
	
end#end controller



