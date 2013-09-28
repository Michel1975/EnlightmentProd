class Merchant::MerchantMembersController < Merchant::BaseController
	before_filter :require_login
	layout :determine_layout

	#To be used from merchant portal when manually creating new subscriber from scrath - more logic needed
	def new
		@member = Member.new
	end

	#To be used from merchant portal when manually creating new subscriber from scrath - more logic needed
	def create
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
        		format.html { render action: 'new'}
      		end
      	end
    end


    def show
    end
end
